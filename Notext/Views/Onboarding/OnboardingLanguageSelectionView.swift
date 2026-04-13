import SwiftUI

struct OnboardingLanguageSelectionView: View {
    @Binding var hasCompletedOnboarding: Bool
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    @EnvironmentObject private var transcriptionModelManager: TranscriptionModelManager
    
    @StateObject private var whisperPrompt = WhisperPrompt()

    @State private var scale: CGFloat = 0.8
    @State private var opacity: CGFloat = 0
    @State private var showModelDownload = false
    
    var body: some View {
        ZStack {
            if showModelDownload {
                OnboardingModelDownloadView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                GeometryReader { geometry in
                    // Reusable background
                    OnboardingBackgroundView()

                    VStack(spacing: 40) {
                        // Language icon
                        VStack(spacing: 30) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "globe")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)

                            // Title and description
                            VStack(spacing: 12) {
                                Text("Select Your Language")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("Choose the language for voice transcription. You can change this later in settings.")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }

                        // Language selection card
                        if isModelMultilingual() {
                            styledLanguagePicker(
                                selectedLanguage: $selectedLanguage,
                                languages: getSupportedLanguages()
                            )
                            .scaleEffect(scale)
                            .opacity(opacity)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "text.badge.checkmark")
                                    .font(.system(size: 36))
                                    .foregroundColor(.accentColor)

                                Text("English-Only Model")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("The current model is optimized for English transcription.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: 400)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }

                        // Action buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                updateLanguage()
                                withAnimation {
                                    showModelDownload = true
                                }
                            }) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .opacity(opacity)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(width: min(geometry.size.width * 0.8, 600))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }
    
    private func isModelMultilingual() -> Bool {
        guard let currentModel = transcriptionModelManager.currentTranscriptionModel else {
            return false
        }
        return currentModel.isMultilingualModel
    }
    
    private func getSupportedLanguages() -> [String: String] {
        guard let currentModel = transcriptionModelManager.currentTranscriptionModel else {
            return ["en": "English"]
        }
        return currentModel.supportedLanguages
    }
    
    private func getCurrentModelName() -> String {
        return transcriptionModelManager.currentTranscriptionModel?.displayName ?? "Unknown"
    }
    
    private func updateLanguage() {
        // Update the prompt for the selected language
        whisperPrompt.updateTranscriptionPrompt()

        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
        NotificationCenter.default.post(name: .AppSettingsDidChange, object: nil)
    }

    @ViewBuilder
    private func styledLanguagePicker(
        selectedLanguage: Binding<String>,
        languages: [String: String]
    ) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "globe.badge.ellipsis")
                        .font(.system(size: 24))  
                        .foregroundColor(.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Transcription Language")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Text("Choose the language for voice recognition")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Menu {
                        ForEach(languages.sorted(by: {
                            if $0.key == "auto" { return true }
                            if $1.key == "auto" { return false }
                            return $0.value < $1.value
                        }), id: \.key) { key, value in
                            Button {
                                selectedLanguage.wrappedValue = key
                            } label: {
                                HStack {
                                    Text(value)
                                    if selectedLanguage.wrappedValue == key {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(languages[selectedLanguage.wrappedValue] ?? "Select")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .medium))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            .padding()
            .frame(maxWidth: 400)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
