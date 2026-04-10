import Foundation

struct OllamaGenerateRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
}

struct OllamaGenerateResponse: Codable {
    let response: String
    let done: Bool
}

class OllamaService {
    static let shared = OllamaService()
    
    // Le modèle peut être modifié. Ex: llama3, mistral, phi3
    var defaultModel = "llama3" 
    
    func generatePrompt(from text: String, tone: PromptTone) async throws -> String {
        let url = URL(string: "http://localhost:11434/api/generate")!
        
        let finalPrompt = tone.buildPrompt(for: text)
        
        let requestBody = OllamaGenerateRequest(
            model: defaultModel,
            prompt: finalPrompt,
            stream: false
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSLocalizedString("Réponse du serveur invalide.", comment: "") as! Error
        }
        
        if httpResponse.statusCode != 200 {
            throw NSError(
                domain: "OllamaAIEngine",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Erreur Ollama (code \(httpResponse.statusCode)). Assurez-vous que l'application Ollama est lancée en arrière-plan et que le modèle '\(defaultModel)' est installé (ex: 'ollama run \(defaultModel)')."]
            )
        }
        
        let ollamaResponse = try JSONDecoder().decode(OllamaGenerateResponse.self, from: data)
        return ollamaResponse.response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isOllamaRunning() async -> Bool {
        guard let url = URL(string: "http://localhost:11434/") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 2.0
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
