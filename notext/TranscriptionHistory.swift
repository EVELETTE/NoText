import Foundation
import SwiftUI
import Combine

class Transcript: Identifiable {
    let id: UUID = UUID()
    var text: String
    var originalText: String
    var duration: TimeInterval
    var timestamp: Date
    var audioFileName: String?
    var isReformulated: Bool
    
    init(text: String, originalText: String, duration: TimeInterval, audioFileName: String? = nil, isReformulated: Bool = false) {
        self.text = text
        self.originalText = originalText
        self.duration = duration
        self.timestamp = Date()
        self.audioFileName = audioFileName
        self.isReformulated = isReformulated
    }
}

class TranscriptionHistory: ObservableObject {
    @Published var transcripts: [Transcript] = []
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadTranscripts()
    }
    
    func addTranscript(_ transcript: Transcript) {
        transcripts.insert(transcript, at: 0)
        saveTranscripts()
    }
    
    func deleteTranscript(_ transcript: Transcript) {
        transcripts.removeAll { $0.id == transcript.id }
        saveTranscripts()
    }
    
    func clearHistory() {
        transcripts.removeAll()
        saveTranscripts()
    }
    
    func exportTranscript(_ transcript: Transcript) -> URL? {
        let formatter = ISO8601DateFormatter()
        let fileName = "transcript_\(formatter.string(from: transcript.timestamp)).txt"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            let content = """
            Transcription - \(transcript.timestamp.formatted(date: .long, time: .shortened))
            Durée: \(String(format: "%.1f", transcript.duration))s
            Reformulé: \(transcript.isReformulated ? "Oui" : "Non")
            
            \(transcript.text)
            """
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
    
    func exportAllTranscripts() -> URL? {
        let formatter = ISO8601DateFormatter()
        let fileURL = documentsDirectory.appendingPathComponent("all_transcripts_\(formatter.string(from: Date())).txt")
        
        do {
            var content = "=== HISTORIQUE DES TRANSCRIPTIONS ===\n\n"
            for transcript in transcripts {
                content += """
                --- Transcription du \(transcript.timestamp.formatted(date: .long, time: .shortened)) ---
                Durée: \(String(format: "%.1f", transcript.duration))s
                Reformulé: \(transcript.isReformulated ? "Oui" : "Non")
                
                \(transcript.text)
                
                """
            }
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Export all error: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTranscripts() {
        // Load from UserDefaults for simplicity
        if let data = UserDefaults.standard.data(forKey: "transcripts"),
           let decoded = try? JSONDecoder().decode([TranscriptData].self, from: data) {
            transcripts = decoded.map { data in
                Transcript(
                    text: data.text,
                    originalText: data.originalText,
                    duration: data.duration,
                    audioFileName: data.audioFileName,
                    isReformulated: data.isReformulated
                )
            }
        }
    }
    
    private func saveTranscripts() {
        let data = transcripts.map { transcript in
            TranscriptData(
                text: transcript.text,
                originalText: transcript.originalText,
                duration: transcript.duration,
                audioFileName: transcript.audioFileName,
                isReformulated: transcript.isReformulated
            )
        }
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "transcripts")
        }
    }
}

// Data structure for serialization
struct TranscriptData: Codable {
    let text: String
    let originalText: String
    let duration: TimeInterval
    let audioFileName: String?
    let isReformulated: Bool
}
