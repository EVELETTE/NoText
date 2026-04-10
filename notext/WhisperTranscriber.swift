import Foundation
import Combine
import SwiftUI

class WhisperTranscriber: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcriptionProgress: Double = 0.0
    
    private let apiKey: String?
    
    init() {
        // Try to get API key from environment or local config
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    
    /// Transcribe audio file using local Whisper model
    /// For true local execution, we'll use the whisper-cpp or openai-whisper CLI
    func transcribe(audioFileURL: URL) async throws -> String {
        guard !isTranscribing else {
            throw TranscriptionError.alreadyTranscribing
        }
        
        isTranscribing = true
        transcriptionProgress = 0.0
        
        defer {
            isTranscribing = false
            transcriptionProgress = 1.0
        }
        
        // Use openai-whisper CLI if installed
        // Install via: pip install openai-whisper
        let transcription = try await transcribeWithLocalWhisper(audioFileURL: audioFileURL)
        
        return transcription
    }
    
    private func transcribeWithLocalWhisper(audioFileURL: URL) async throws -> String {
        // Check if whisper CLI is available
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        
        // Using whisper-cli or python whisper
        // For now, we'll use a shell command approach
        let script = """
        if command -v whisper &> /dev/null; then
            whisper "\(audioFileURL.path)" --model base --output_format txt --output_dir "\(audioFileURL.deletingLastPathComponent().path)"
        else
            echo "Whisper not installed"
            exit 1
        fi
        """
        
        process.arguments = ["bash", "-c", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            throw TranscriptionError.whisperFailed(output)
        }
        
        // Read the output text file
        let outputFileURL = audioFileURL.deletingPathExtension().appendingPathExtension("txt")
        
        if FileManager.default.fileExists(atPath: outputFileURL.path) {
            return try String(contentsOf: outputFileURL, encoding: .utf8)
        }
        
        return ""
    }
    
    /// Reformulate the transcribed text using a local prompt optimization system
    func reformulateTranscript(_ text: String, options: PromptOptions) -> String {
        var result = text
        
        // Apply text cleaning and optimization
        if options.removeFillers {
            // Remove common filler words (French and English)
            let fillers = ["euh", "uh", "um", "donc", "bas", "alors", "enfin", "voilà", "like", "you know"]
            for filler in fillers {
                result = result.replacingOccurrences(
                    of: "\\b\(filler)\\b",
                    with: "",
                    options: .regularExpression,
                    range: nil
                )
            }
        }
        
        // Remove multiple spaces
        result = result.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression,
            range: nil
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Capitalize first letter of sentences
        if options.fixCapitalization {
            result = fixCapitalization(result)
        }
        
        // Add punctuation if missing
        if options.addPunctuation {
            result = addMissingPunctuation(result)
        }
        
        return result
    }
    
    private func fixCapitalization(_ text: String) -> String {
        let sentences = text.split(separator: ".")
        return sentences.map { sentence in
            let trimmed = sentence.trimmingCharacters(in: .whitespaces)
            guard let firstChar = trimmed.first else { return trimmed }
            return String(firstChar).uppercased() + trimmed.dropFirst()
        }.joined(separator: ". ")
    }
    
    private func addMissingPunctuation(_ text: String) -> String {
        // Simple heuristic: add period at the end if no punctuation
        guard !text.isEmpty else { return text }
        let lastChar = text.last!
        let punctuation: Set<Character> = [".", "!", "?", ","]
        
        if !punctuation.contains(lastChar) {
            return text + "."
        }
        return text
    }
}

enum TranscriptionError: Error, LocalizedError {
    case alreadyTranscribing
    case whisperFailed(String)
    case fileNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .alreadyTranscribing:
            return "A transcription is already in progress"
        case .whisperFailed(let output):
            return "Whisper transcription failed: \(output)"
        case .fileNotFound(let path):
            return "Audio file not found: \(path)"
        }
    }
}

struct PromptOptions {
    var removeFillers: Bool = true
    var fixCapitalization: Bool = true
    var addPunctuation: Bool = true
    var optimizeForReadability: Bool = true
}
