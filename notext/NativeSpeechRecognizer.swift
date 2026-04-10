import Foundation
import Speech
import AVFoundation
import Combine

class NativeSpeechRecognizer: ObservableObject {
    @Published var isTranscribing = false
    @Published var currentTranscription: String = ""
    @Published var errorMessage: String?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        print("🔍 Initializing speech recognizer...")
        
        // Set explicitly to French
        if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR")) {
            speechRecognizer = recognizer
            print("✅ Speech recognizer created")
            print("   - Available: \(recognizer.isAvailable)")
        } else {
            print("❌ Could not create speech recognizer")
        }
    }
    
    /// Check if speech recognition is available
    func checkAuthorization() -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        let available = speechRecognizer?.isAvailable ?? false
        
        print("🔍 Authorization check:")
        print("   - Status: \(status.rawValue) (authorized: \(status == .authorized))")
        print("   - Recognizer available: \(available)")
        
        return status == .authorized && available
    }
    
    /// Request authorization for speech recognition
    func requestAuthorization() {
        print("🎤 Requesting authorization...")
        SFSpeechRecognizer.requestAuthorization { status in
            print("🎤 Authorization result: \(status.rawValue)")
        }
    }
    
    /// Start live speech recognition
    func startRecognition(language: String, onPartialResult: @escaping (String) -> Void) async throws {
        print("🎤 Starting speech recognition in \(language)...")
        
        // Mettre à jour la langue dynamiquement si nécessaire
        if speechRecognizer?.locale.identifier != language {
            if let newRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language)) {
                speechRecognizer = newRecognizer
            } else {
                throw SpeechError.recognizerNotAvailable
            }
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerNotAvailable
        }
        
        // Clean up any previous session
        stopRecognition()
        
        let engine = AVAudioEngine()
        audioEngine = engine
        let inputNode = engine.inputNode
        
        // NE PAS UTILISER setVoiceProcessingEnabled sur des micros à 9 canaux (cause AUVPAggregate err=-50)
        
        let hwFormat = inputNode.outputFormat(forBus: 0)
        print("📊 Input format: \(hwFormat.sampleRate)Hz, \(hwFormat.channelCount) channels")
        
        if hwFormat.channelCount == 0 || hwFormat.sampleRate == 0 {
            print("❌ Invalid input format")
            throw SpeechError.audioEngineFailed
        }
        
        // Create recognition request
        let request = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest = request
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        
        if #available(macOS 13, *) {
            request.requiresOnDeviceRecognition = true
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: hwFormat) { [weak self] buffer, time in
            guard let self = self else { return }
            
            if hwFormat.channelCount == 1 {
                self.recognitionRequest?.append(buffer)
            } else {
                // Créer manuellement un buffer mono avec la même fréquence et copier juste le premier canal
                guard let monoFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: hwFormat.sampleRate, channels: 1, interleaved: false),
                      let monoBuffer = AVAudioPCMBuffer(pcmFormat: monoFormat, frameCapacity: buffer.frameLength) else { return }
                
                monoBuffer.frameLength = buffer.frameLength
                
                // Copie directe en mémoire (bypass total de AVAudioConverter et de ses règles strictes)
                if let sourceData = buffer.floatChannelData?[0], let destData = monoBuffer.floatChannelData?[0] {
                    // Copie rapide en C
                    destData.update(from: sourceData, count: Int(buffer.frameLength))
                    self.recognitionRequest?.append(monoBuffer)
                }
            }
        }
        print("✅ Tap installed and direct channel extraction ready")
        
        do {
            engine.prepare()
            try engine.start()
            print("✅ Audio engine started")
        } catch {
            print("❌ Audio engine failed: \(error.localizedDescription)")
            throw SpeechError.audioEngineFailed
        }
        
        isTranscribing = true
        errorMessage = nil
        
        var finalizedBuffer: [String] = []
        var previousString: String = ""
        
        // Start recognition
        print("🎤 Starting recognition task...")
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let currentString = result.bestTranscription.formattedString
                
                // Détection d'une coupure/réinitialisation native de SFSpeechRecognizer :
                // Si la nouvelle chaîne est significativement plus petite que la précédente
                // (et qu'elle n'est pas juste une correction mineure), on sauvegarde l'ancienne.
                if currentString.count < (previousString.count / 2) && !previousString.isEmpty {
                    print("⚠️ Buffer speech engine reset détecté, sauvegarde: '\(previousString)'")
                    finalizedBuffer.append(previousString)
                }
                
                previousString = currentString
                
                // On assemble l'historique et le flux actuel
                var allTextParts = finalizedBuffer
                if !currentString.isEmpty {
                    allTextParts.append(currentString)
                }
                let text = allTextParts.joined(separator: " ")
                
                self.currentTranscription = text
                
                DispatchQueue.main.async {
                    onPartialResult(text)
                }
            }
            
            if let error = error {
                print("❌ Error: \(error.localizedDescription) (code: \(error._code))")
                // Si l'erreur est temporelle (pause trop longue), on devrait théoriquement redémarrer,
                // mais on garde déjà le buffer sécurisé. L'enregistrement s'arrête gentiment.
            }
        }
        
        print("✅ Recognition started")
    }
    
    /// Stop speech recognition
    func stopRecognition() {
        print("⏹️ Stopping recognition...")
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        audioEngine = nil
        
        isTranscribing = false
        print("✅ Recognition stopped")
    }
}

enum SpeechError: Error, LocalizedError {
    case recognizerNotAvailable
    case audioEngineFailed
    case requestFailed
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .recognizerNotAvailable:
            return "Reconnaissance vocale non disponible"
        case .audioEngineFailed:
            return "Impossible d'accéder au microphone. Vérifiez dans Préférences Système > Confidentialité > Micro"
        case .requestFailed:
            return "Échec de la demande"
        case .notAuthorized:
            return "Accès au microphone non autorisé"
        }
    }
}
