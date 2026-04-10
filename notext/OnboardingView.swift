import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var currentStep = 0
    @Environment(\.dismiss) var dismiss
    
    private let totalSteps = 6
    
    var body: some View {
        ZStack {
            // Fond sombre Premium
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre de progression discrète en haut
                HStack(spacing: 4) {
                    ForEach(0..<totalSteps) { index in
                        Capsule()
                            .fill(index <= currentStep ? LinearGradient(colors: [.cyan, .mint], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.secondary.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 4)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                ZStack {
                    if currentStep == 0 {
                        languageSelectionStep()
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if currentStep == 1 {
                        onboardingStep(
                            index: 1,
                            title: "Bienvenue sur NoText",
                            description: "Transformez vos paroles en prompts structurés instantanément. C'est simple, rapide et 100% privé.",
                            systemImage: "waveform.circle.fill",
                            color: .blue
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if currentStep == 2 {
                        newFeaturesStep()
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if currentStep == 3 {
                        onboardingStep(
                            index: 3,
                            title: "Push-To-Talk Global",
                            description: "Maintenez la touche **Option (⌥)** n'importe où sur votre Mac pour parler. Relâchez, l'IA fait le reste.",
                            systemImage: "keyboard",
                            color: .cyan
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if currentStep == 4 {
                        onboardingStep(
                            index: 4,
                            title: "IA Locale Gemini",
                            description: "Propulsé par Gemma (Google) & MLX (Apple). Vos données ne quittent jamais votre Mac. Confidentialité evecorp garantie.",
                            systemImage: "cpu",
                            color: .purple
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if currentStep == 5 {
                        onboardingStep(
                            index: 5,
                            title: "Auto-Paste Magique",
                            description: "Une fois le prompt généré, NoText le tape directement là où se trouve votre curseur. Plus besoin de copier-coller !",
                            systemImage: "doc.on.clipboard.fill",
                            color: .green
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
                .animation(.easeInOut, value: currentStep)
                
                // Barre d'action basse
                HStack {
                    if currentStep < totalSteps - 1 {
                        Button("Passer") {
                            completeOnboarding()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentStep += 1
                            }
                        }) {
                            HStack {
                                Text("Suivant")
                                Image(systemName: "chevron.right")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(VisualEffectView(material: .selection, blendingMode: .withinWindow))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("C'est parti !")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(LinearGradient(colors: [.cyan, .mint], startPoint: .leading, endPoint: .trailing))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.cyan.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                    }
                }
                .padding(30)
                .padding(.bottom, 10)
            }
        }
        .frame(width: 550, height: 480)
    }
    
    // Étape 0 : Sélection de langue
    private func languageSelectionStep() -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "globe")
                    .font(.system(size: 50))
                    .foregroundStyle(LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            
            VStack(spacing: 16) {
                Text("Choisissez votre langue")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                
                Picker("", selection: $viewModel.transcriptionLanguage) {
                    Text("Français (France)").tag("fr-FR")
                    Text("English (US)").tag("en-US")
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
            
            Text("Vous pourrez changer cela à tout moment dans les réglages.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // Étape 2 : Nouvelles fonctionnalités
    private func newFeaturesStep() -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Nouveautés NoText")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 15) {
                featureRow(icon: "clock.arrow.circlepath", text: "Historique local des 50 dernières notes.")
                featureRow(icon: "translate", text: "Traduction automatique vers l'anglais.")
                featureRow(icon: "hand.tap.fill", text: "Retours haptiques et sonores au clic.")
                featureRow(icon: "music.note.list", text: "Transcription de fichiers audio par Drag & Drop.")
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    private func onboardingStep(index: Int, title: String, description: String, systemImage: String, color: Color) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icone Neon Style
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: systemImage)
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color.cyan.opacity(0.5), radius: 10)
            }
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text(LocalizedStringKey(description))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .tag(index)
    }
    
    private func completeOnboarding() {
        viewModel.hasCompletedOnboarding = true
        viewModel.showOnboarding = false
        dismiss()
    }
}
