import Foundation

class MLXInstallationService {
    var isMlxInstalled = false
    var isInstalling = false
    var installationError: String? = nil
    
    init() {
        checkMlxInstallation()
    }
    
    func checkMlxInstallation() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", "-c", "import mlx_lm"]
        
        do {
            try process.run()
            process.waitUntilExit()
            DispatchQueue.main.async {
                self.isMlxInstalled = (process.terminationStatus == 0)
            }
        } catch {
            DispatchQueue.main.async {
                self.isMlxInstalled = false
            }
        }
    }
    
    func installMlxAutomatically() async {
        await MainActor.run {
            self.isInstalling = true
            self.installationError = nil
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["bash", "-c", "pip3 install mlx-lm huggingface_hub"]
        
        let pipeErr = Pipe()
        process.standardError = pipeErr
        process.environment = ProcessInfo.processInfo.environment
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                await MainActor.run {
                    self.isMlxInstalled = true
                    self.isInstalling = false
                }
            } else {
                let data = pipeErr.fileHandleForReading.readDataToEndOfFile()
                let errorMsg = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                await MainActor.run {
                    self.installationError = "Échec de l'installation : \(errorMsg)"
                    self.isInstalling = false
                }
            }
        } catch {
            await MainActor.run {
                self.installationError = "Erreur lors de l'exécution: \(error.localizedDescription)"
                self.isInstalling = false
            }
        }
    }
}
