import Foundation
import SwiftUI
import Combine

@MainActor
class TranscriptionViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var currentTranscription = ""
    @Published var originalTranscription = ""
    @Published var isReformulated = false
    @Published var errorMessage: String?
    @Published var showHistory = false
    @Published var recordingDuration: TimeInterval = 0
    
    // Onboarding
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var showOnboarding: Bool = false
    
    // Nouveaux états IA
    @AppStorage("transcriptionLanguage") var transcriptionLanguage: String = "fr-FR"
    @AppStorage("targetLanguage") var targetLanguage: String = ""
    @AppStorage("isTranslationEnabled") var isTranslationEnabled: Bool = false
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    @AppStorage("customInstruction") var customInstruction: String = "Agis comme un expert en rédaction."
    
    @Published var selectedTone: PromptTone = .direct
    @Published var isGeneratingAI = false
    @Published var finalPrompt = ""
    @Published var downloadProgress: String? = nil
    @Published var animationFrame = 0
    
    // Installation MLX
    @Published var showInstallationPrompt = false
    @Published var isMlxInstalled = false
    @Published var isInstalling: Bool = false
    
    // Services
    private let nativeRecognizer = NativeSpeechRecognizer()
    private let mlxService = MLXService.shared
    private let whisperTranscriber = WhisperTranscriber()
    let installationService = MLXInstallationService()
    let shortcutManager = GlobalShortcutManager()
    let historyManager = HistoryManager.shared
    
    private var recordingTimer: Timer?
    
    init() {
        checkMlxStatus()
        setupShortcuts()
        
        // Déclencher l'onboarding au démarrage si jamais fait
        if !hasCompletedOnboarding {
            self.showOnboarding = true
        }
        
        // Timer global pour l'animation de l'icône
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.animationFrame += 1
            }
        }
    }
    
    private func setupShortcuts() {
        shortcutManager.onKeyDown = { [weak self] in
            guard let self = self, !self.isRecording else { return }
            self.playFeedback(isStart: true)
            self.startRecording()
        }
        
        shortcutManager.onKeyUp = { [weak self] in
            guard let self = self, self.isRecording else { return }
            self.playFeedback(isStart: false)
            Task {
                await self.stopRecording(autoPaste: true)
            }
        }
    }
    
    private func playFeedback(isStart: Bool) {
        if isHapticEnabled {
            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        }
        if isSoundEnabled {
            if isStart {
                NSSound(named: "Pop")?.play()
            } else {
                NSSound(named: "Bottle")?.play()
            }
        }
    }
    
    func checkMlxStatus() {
        installationService.checkMlxInstallation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isMlxInstalled = self.installationService.isMlxInstalled
            if !self.isMlxInstalled {
                self.showInstallationPrompt = true
            }
        }
    }
    
    // MARK: - Recording
    
    func toggleRecording() {
        if isRecording {
            Task { await stopRecording() }
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        guard nativeRecognizer.checkAuthorization() else {
            nativeRecognizer.requestAuthorization()
            errorMessage = "Veuillez autoriser l'accès à la reconnaissance vocale et au micro."
            return
        }
        
        isRecording = true
        currentTranscription = ""
        originalTranscription = ""
        finalPrompt = ""
        isReformulated = false
        errorMessage = nil
        recordingDuration = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.recordingDuration += 1
            }
        }
        
        Task {
            do {
                try await nativeRecognizer.startRecognition(language: transcriptionLanguage) { [weak self] partialResult in
                    self?.currentTranscription = partialResult
                }
            } catch {
                errorMessage = "Erreur de reconnaissance vocale: \(error.localizedDescription)"
                isRecording = false
                recordingTimer?.invalidate()
            }
        }
    }
    
    func stopRecording(autoPaste: Bool = false) async {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        nativeRecognizer.stopRecognition()
        
        // Save the raw text
        originalTranscription = nativeRecognizer.currentTranscription
        if originalTranscription.isEmpty {
            originalTranscription = currentTranscription
        }
        
        await generatePrompt()
        
        if autoPaste && isReformulated && !finalPrompt.isEmpty {
            copyToClipboard(finalPrompt)
            // Laisse le temps au presse-papier de se mettre à jour
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            shortcutManager.simulatePaste()
        }
        
        // Sauvegarder dans l'historique
        if isReformulated && !finalPrompt.isEmpty {
            historyManager.saveTranscription(
                original: originalTranscription,
                result: finalPrompt,
                tone: selectedTone.rawValue,
                language: transcriptionLanguage
            )
        }
    }
    
    func cancelRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        nativeRecognizer.stopRecognition()
        currentTranscription = ""
        originalTranscription = ""
    }
    
    // MARK: - Generation
    
    func generatePrompt() async {
        let textToUse = originalTranscription.isEmpty ? currentTranscription : originalTranscription
        guard !textToUse.isEmpty else { return }
        
        isGeneratingAI = true
        isReformulated = false
        errorMessage = nil
        downloadProgress = nil
        finalPrompt = "Génération du prompt par l'IA en cours..."
        
        do {
            let targetLang = isTranslationEnabled && !targetLanguage.isEmpty ? targetLanguage : nil
            let customInst = selectedTone == .custom ? customInstruction : nil
            
            let result = try await mlxService.generatePrompt(
                from: textToUse,
                tone: selectedTone,
                customInstruction: customInst,
                targetLanguage: targetLang
            ) { progress in
                DispatchQueue.main.async {
                    self.downloadProgress = progress
                }
            }
            finalPrompt = result
            isReformulated = true
        } catch {
            errorMessage = "Erreur IA: \(error.localizedDescription)"
            finalPrompt = ""
        }
        
        isGeneratingAI = false
    }
    
    // MARK: - Audio Files
    
    func processAudioFile(url: URL) {
        Task {
            isGeneratingAI = true
            finalPrompt = "Transcription du fichier audio..."
            errorMessage = nil
            
            do {
                let transcription = try await whisperTranscriber.transcribe(audioFileURL: url)
                await MainActor.run {
                    self.originalTranscription = transcription
                    self.currentTranscription = transcription
                }
                await generatePrompt()
            } catch {
                errorMessage = "Erreur fichier audio: \(error.localizedDescription)"
                isGeneratingAI = false
            }
        }
    }
    
    // MARK: - Utilities
    
    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
