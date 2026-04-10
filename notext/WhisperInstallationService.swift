import Foundation
import Combine
import SwiftUI

@MainActor
class WhisperInstallationService: ObservableObject {
    @Published var isCheckingInstallation = false
    @Published var isInstalling = false
    @Published var isWhisperInstalled = false
    @Published var installationProgress: String = ""
    @Published var installationProgressPercent: Double = 0.0
    @Published var installationError: String?
    
    private let defaultsKey = "whisperInstallationChecked"
    
    init() {
        // Check on init
        isWhisperInstalled = checkWhisperInstallation()
    }
    
    /// Check if Whisper CLI is available
    func checkWhisperInstallation() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["which", "whisper"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let installed = process.terminationStatus == 0
            print("🔍 Whisper check: \(installed ? "INSTALLED" : "NOT INSTALLED")")
            return installed
        } catch {
            print("❌ Whisper check failed: \(error)")
            return false
        }
    }
    
    /// Open Terminal with installation instructions
    func openTerminalWithInstructions() {
        let instructions = """
        # Installation de Whisper pour NoText
        # Copiez et exécutez ces commandes une par une :
        
        # 1. Installer Python si pas déjà fait
        brew install python
        
        # 2. Installer Whisper
        pip3 install openai-whisper
        
        # 3. Vérifier
        which whisper
        
        """
        
        // Open Terminal
        let terminalURL = URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app")
        NSWorkspace.shared.open(terminalURL)
        
        // Copy instructions to clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        
        installationProgress = "✅ Terminal ouvert ! Instructions copiées dans le presse-papiers"
        installationProgressPercent = 0.5
    }
    
    /// Try automatic installation
    func installWhisperAutomatically() async {
        guard !isInstalling else { return }
        
        isInstalling = true
        installationError = nil
        installationProgressPercent = 0.0
        
        do {
            installationProgress = "Tentative d'installation automatique..."
            installationProgressPercent = 0.1
            
            // Try to install via pip3
            let script = """
            export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
            pip3 install openai-whisper 2>&1
            """
            
            try await runScript(script)
            installationProgressPercent = 0.7
            
            installationProgress = "Configuration..."
            installationProgressPercent = 0.85
            
            // Create symlink if needed
            let linkScript = """
            export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
            WHISPER_BIN=$(python3 -m site --user-base 2>/dev/null)/bin/whisper
            if [ -f "$WHISPER_BIN" ]; then
                ln -sf "$WHISPER_BIN" /usr/local/bin/whisper 2>/dev/null
            fi
            """
            try await runScript(linkScript)
            
            // Verify
            installationProgress = "Vérification..."
            installationProgressPercent = 0.95
            
            isWhisperInstalled = checkWhisperInstallation()
            
            if isWhisperInstalled {
                installationProgress = "✅ Installation réussie !"
                installationProgressPercent = 1.0
                UserDefaults.standard.set(true, forKey: defaultsKey)
            } else {
                throw InstallationError.installationFailed("Whisper n'a pas pu être vérifié")
            }
            
        } catch {
            installationError = error.localizedDescription
            isWhisperInstalled = false
        }
        
        isInstalling = false
    }
    
    private func runScript(_ script: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        
        while process.isRunning {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
        
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            print("❌ Script failed: \(output)")
            throw InstallationError.installationFailed(output)
        }
    }
    
    func checkAgain() {
        isWhisperInstalled = checkWhisperInstallation()
    }
}

enum InstallationError: Error, LocalizedError {
    case installationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .installationFailed(let details):
            return "Échec: \(details)"
        }
    }
}
