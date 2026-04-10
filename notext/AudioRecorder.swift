import Foundation
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var audioData: [Int16] = []
    private var tempFileURL: URL?
    
    override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Target format: 16kHz mono for Whisper
        let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                         sampleRate: 16000,
                                         channels: 1,
                                         interleaved: true)
        
        guard let targetFormat = targetFormat else {
            print("Failed to create target format")
            return
        }
        
        // Create converter
        guard let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
            print("Failed to create converter")
            return
        }
        
        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, time in
            // Calculate audio level
            if let channelData = buffer.floatChannelData?[0] {
                var sum: Float = 0
                for i in 0..<Int(buffer.frameLength) {
                    sum += abs(channelData[i])
                }
                let level = sum / Float(buffer.frameLength)
                
                DispatchQueue.main.async {
                    self.audioLevel = level
                }
            }
            
            // Convert audio data
            var error: NSError?
            let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }
            
            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat,
                                                   frameCapacity: AVAudioFrameCount(buffer.frameLength))!
            
            converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)
            
            // Store converted data
            if let convertedData = convertedBuffer.int16ChannelData?[0] {
                for i in 0..<Int(convertedBuffer.frameLength) {
                    self.audioData.append(convertedData[i])
                }
            }
        }
    }
    
    func startRecording() async throws -> URL {
        guard let audioEngine = audioEngine else {
            throw NSError(domain: "AudioRecorder", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Audio engine not initialized"])
        }
        
        // Clear previous data
        audioData.removeAll()
        
        // Generate temp file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("recording_\(Date().timeIntervalSince1970).wav")
        tempFileURL = fileURL
        
        // Prepare and start engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
        
        return fileURL
    }
    
    func stopRecording() async throws -> URL {
        guard let audioEngine = audioEngine, isRecording else {
            throw NSError(domain: "AudioRecorder", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Not recording"])
        }
        
        // Stop engine and remove tap
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        isRecording = false
        audioLevel = 0.0
        
        // Write audio data to WAV file
        guard let fileURL = tempFileURL else {
            throw NSError(domain: "AudioRecorder", code: -2,
                         userInfo: [NSLocalizedDescriptionKey: "No file URL"])
        }
        
        try writeWAVFile(url: fileURL, samples: audioData)
        
        // Clear audio data
        audioData.removeAll()
        
        return fileURL
    }
    
    func cancelRecording() {
        if isRecording {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
            isRecording = false
            audioLevel = 0.0
            audioData.removeAll()
        }
    }
    
    // MARK: - WAV File Writing
    
    private func writeWAVFile(url: URL, samples: [Int16]) throws {
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                        sampleRate: 16000,
                                        channels: 1,
                                        interleaved: true)!
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat,
                                      frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = AVAudioFrameCount(samples.count)
        
        // Copy samples to buffer
        guard let channelData = buffer.int16ChannelData?[0] else {
            throw NSError(domain: "AudioRecorder", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to get channel data"])
        }
        
        samples.enumerated().forEach { index, sample in
            channelData[index] = sample
        }
        
        // Create AVAudioFile and write
        let audioFile = try AVAudioFile(forWriting: url,
                                        settings: audioFormat.settings,
                                        commonFormat: audioFormat.commonFormat,
                                        interleaved: audioFormat.isInterleaved)
        
        try audioFile.write(from: buffer)
    }
}
