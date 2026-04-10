import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    
    var body: some View {
        TabView {
            // 1. GÉNÉRAL & SYSTÈME
            Form {
                Section(header: Text("Système").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accès Accessibilité")
                            .font(.subheadline.bold())
                        
                        if viewModel.shortcutManager.isAccessibilityGranted {
                            Label("Autorisé", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            HStack {
                                Label("Non Autorisé", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Spacer()
                                Button("Régler") {
                                    viewModel.shortcutManager.requestAccessibilityPermissions()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                Section(header: Text("Configuration").font(.headline)) {
                    Picker("Langue de Dictée", selection: $viewModel.transcriptionLanguage) {
                        Text("Français (FR)").tag("fr-FR")
                        Text("English (US)").tag("en-US")
                    }
                    
                    Divider().padding(.vertical, 5)
                    
                    Button("Relancer le tutoriel (Onboarding)") {
                        viewModel.hasCompletedOnboarding = false
                        viewModel.showOnboarding = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    .font(.caption)
                }
            }
            .padding()
            .tabItem {
                Label("Général", systemImage: "gearshape")
            }
            
            // 2. INTELLIGENCE ARTIFICIELLE
            Form {
                Section(header: Text("Personnalisation de l'IA").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Traduire le résultat final", isOn: $viewModel.isTranslationEnabled)
                            .toggleStyle(.switch)
                        
                        if viewModel.isTranslationEnabled {
                            TextField("Vers quelle langue ?", text: $viewModel.targetLanguage)
                                .textFieldStyle(.roundedBorder)
                                .padding(.leading, 20)
                        }
                    }
                    
                    Divider().padding(.vertical, 5)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Prompt pour le mode 'Personnalisé'")
                            .font(.subheadline.bold())
                        TextEditor(text: $viewModel.customInstruction)
                            .font(.system(.caption, design: .monospaced))
                            .frame(height: 70)
                            .padding(6)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                Section(header: Text("Moteur MLX (Apple Silicon)").font(.headline)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gemma 2B IT")
                                .font(.subheadline.bold())
                            Text(viewModel.isMlxInstalled ? "Prêt pour l'exécution locale" : "Moteur non détecté")
                                .font(.caption)
                                .foregroundColor(viewModel.isMlxInstalled ? .secondary : .red)
                        }
                        Spacer()
                        if !viewModel.isMlxInstalled {
                            Button("Installer") {
                                Task { await viewModel.installationService.installMlxAutomatically() }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .tabItem {
                Label("IA Locale", systemImage: "sparkles")
            }
            
            // 3. AUDIO & FEEDBACK
            Form {
                Section(header: Text("Retours Utilisateur").font(.headline)) {
                    Toggle("Retours Sonores", isOn: $viewModel.isSoundEnabled)
                    Toggle("Retours Haptiques (Trackpad)", isOn: $viewModel.isHapticEnabled)
                    
                    Text("Une vibration et un son discret confirment le Push-to-Talk global même quand l'application est en arrière-plan.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
            }
            .padding()
            .tabItem {
                Label("Expérience", systemImage: "speaker.wave.3")
            }
        }
        .frame(width: 500, height: 420)
    }
}
