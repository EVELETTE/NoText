import Foundation
import Combine

struct TranscriptionItem: Codable, Identifiable {
    let id: UUID
    let date: Date
    let originalText: String
    let finalPrompt: String
    let tone: String
    let language: String
    var isFavorite: Bool = false
}

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var items: [TranscriptionItem] = []
    private let fileName = "transcription_history.json"
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = paths[0].appendingPathComponent("NoText", isDirectory: true)
        
        // Créer le dossier NoText s'il n'existe pas
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        
        return appSupport.appendingPathComponent(fileName)
    }
    
    init() {
        loadHistory()
    }
    
    func saveTranscription(original: String, result: String, tone: String, language: String) {
        let newItem = TranscriptionItem(
            id: UUID(),
            date: Date(),
            originalText: original,
            finalPrompt: result,
            tone: tone,
            language: language
        )
        
        items.insert(newItem, at: 0)
        
        // Limiter à 50 éléments pour la performance
        if items.count > 50 {
            items = Array(items.prefix(50))
        }
        
        saveToDisk()
    }
    
    func deleteItem(_ item: TranscriptionItem) {
        items.removeAll { $0.id == item.id }
        saveToDisk()
    }
    
    func clearHistory() {
        items.removeAll()
        saveToDisk()
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL)
        } catch {
            print("❌ Erreur sauvegarde historique: \(error)")
        }
    }
    
    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([TranscriptionItem].self, from: data)
        } catch {
            print("❌ Erreur chargement historique: \(error)")
        }
    }
}
