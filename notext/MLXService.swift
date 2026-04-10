import Foundation

class MLXService {
    static let shared = MLXService()
    
    var isGenerating = false
    
    // Modèle Gemma optimisé Instruct (spécifiquement entraîné pour répondre aux instructions, et non juste auto-compléter)
    let modelName = "mlx-community/quantized-gemma-2b-it"
    
    func generatePrompt(from text: String, tone: PromptTone, customInstruction: String? = nil, targetLanguage: String? = nil, onProgress: ((String) -> Void)? = nil) async throws -> String {
        guard !isGenerating else { 
            throw NSError(domain: "MLXError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Génération déjà en cours"]) 
        }
        
        // Ne peut pas modifier le Published state hors du Main Actor ou sans await MainActor.run
        await MainActor.run { self.isGenerating = true }
        defer { Task { @MainActor in self.isGenerating = false } }
        
        let finalPrompt = tone.buildPrompt(for: text, customInstruction: customInstruction, targetLanguage: targetLanguage)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        
        // Script Python qui utilise mlx_lm. 
        // Le prompt est passé en sys.argv[1] pour éviter les problèmes d'échappement.
        let pythonScript = """
import sys
import warnings
warnings.filterwarnings('ignore') # Ignorer les warnings de huggingface/mlx

try:
    from mlx_lm import load, generate
except ImportError:
    print("ERROR: MLX-LM Not Installed", file=sys.stderr)
    sys.exit(1)

model_name = "\(modelName)"
prompt = sys.argv[1]

try:
    # Le téléchargement est mis en cache
    model, tokenizer = load(model_name)
    
    # Utilisation du Chat Template officiel (indispensable pour les modèles "-it" Instruct)
    messages = [{"role": "user", "content": prompt}]
    
    if hasattr(tokenizer, "apply_chat_template") and tokenizer.chat_template is not None:
        formatted_prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    else:
        formatted_prompt = prompt
        
    response = generate(model, tokenizer, prompt=formatted_prompt, max_tokens=500, verbose=False)
    print(response)
except Exception as e:
    print(f"ERROR: {str(e)}", file=sys.stderr)
    sys.exit(1)
"""
        
        process.arguments = ["python3", "-c", pythonScript, finalPrompt]
        
        let pipeOut = Pipe()
        let pipeErr = Pipe()
        process.standardOutput = pipeOut
        process.standardError = pipeErr
        
        class SafeErrorOutput {
            var value = ""
        }
        let safeError = SafeErrorOutput()
        
        pipeErr.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            
            // On utilise DispatchQueue.main car les handlers de Pipe sont concurrents
            DispatchQueue.main.async {
                safeError.value += str
                
                // Les barres de progression de HuggingFace utilisent souvent \r
                let parts = str.components(separatedBy: CharacterSet(charactersIn: "\r\n"))
                for part in parts where part.contains("%") {
                    let clean = part.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !clean.isEmpty {
                        onProgress?(clean)
                    }
                }
            }
        }
        
        try process.run()
        process.waitUntilExit()
        
        // Clean up
        pipeErr.fileHandleForReading.readabilityHandler = nil
        
        let dataOut = pipeOut.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: dataOut, encoding: .utf8) ?? ""
        
        // Ajouter tout ce qui reste dans stderr au cas où
        let dataErr = pipeErr.fileHandleForReading.readDataToEndOfFile()
        if let lastErr = String(data: dataErr, encoding: .utf8) {
            safeError.value += lastErr
        }
        
        if process.terminationStatus != 0 {
            if safeError.value.contains("MLX-LM Not Installed") {
                 throw NSError(domain: "MLXError", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "La librairie MLX n'est pas installée. Veuillez lancer l'installation automatisée."])
            }
            throw NSError(domain: "MLXError", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Erreur IA: \(safeError.value)"])
        }
        
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
