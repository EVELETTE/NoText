import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var showCopyConfirmation = false
    @State private var showHistory = false
    @State private var isTargeted = false
    
    var body: some View {
        VStack(spacing: 0) {
            // HEADER PREMIUM NEON
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(NSColor.windowBackgroundColor))
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                    
                    Image(systemName: "waveform")
                        .foregroundStyle(LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.system(size: 20, weight: .bold))
                }
                .frame(width: 44, height: 44)
                .shadow(color: Color.cyan.opacity(0.3), radius: 5, x: 0, y: 0)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("NoText")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("IA Locale : Gemma 2B")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Statut Pilule
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isMlxInstalled ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(viewModel.isMlxInstalled ? "Prêt à Générer" : "Modèle Absent")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.15))
                .clipShape(Capsule())
                
                // BOUTON HISTORIQUE
                Button(action: { showHistory = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(.plain)
                .help("Historique des transcriptions")
                
                // BOUTON DON (COFFEE)
                Button(action: {
                    if let url = URL(string: "https://checkout.revolut.com/pay/3416e235-8967-497a-8353-3ab929cf35a1") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                .buttonStyle(.plain)
                .help("Offrir un café à evecorp ☕️")
                
                // Raccourci Paramètres
                SettingsLink {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
                .help("Ouvrir les Réglages (Cmd + ,)")
            }
            .padding()
            .background(VisualEffectView(material: .titlebar, blendingMode: .withinWindow))
            
            Divider()
            
            // MAIN CONTENT
            VStack(spacing: 20) {
                
                // Gros Bouton d'enregistrement central (Style Néon Original)
                ZStack {
                    // Anneau extérieur réactif
                    Circle()
                        .stroke(viewModel.isRecording ? Color.red.opacity(0.4) : Color.cyan.opacity(0.15), lineWidth: viewModel.isRecording ? Double(viewModel.animationFrame % 2 == 0 ? 12 : 2) : 2)
                        .frame(width: 140, height: 140)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.animationFrame)
                    
                    Button(action: {
                        viewModel.toggleRecording()
                    }) {
                        ZStack {
                            // Fond creux
                            Circle()
                                .fill(Color(NSColor.controlBackgroundColor))
                            
                            // Bordure fluo
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: viewModel.isRecording ? [.red, .orange] : [.cyan, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                            
                            // Icône fluo
                            Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 38, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: viewModel.isRecording ? [.red, .orange] : [.cyan, .mint],
                                        startPoint: .topTrailing,
                                        endPoint: .bottomLeading
                                    )
                                )
                        }
                        .frame(width: 90, height: 90)
                        .shadow(color: viewModel.isRecording ? Color.red.opacity(0.5) : Color.cyan.opacity(0.4), radius: viewModel.isRecording ? 15 : 8, x: 0, y: 0)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.isMlxInstalled)
                }
                .padding(.top, 10)
                
                // Indicateur de temps si enregistrement
                Text(viewModel.isRecording ? formattedDuration(viewModel.recordingDuration) : " ")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(viewModel.isRecording ? .red : .clear)
                
                // Champs de textes symétriques
                HStack(spacing: 20) {
                    
                    // BROUILLON
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brouillon Vocal")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: .constant(viewModel.currentTranscription.isEmpty ? "Appuyez sur le micro et parlez librement..." : viewModel.currentTranscription))
                            .font(.body)
                            .foregroundColor(viewModel.currentTranscription.isEmpty ? .secondary : .primary)
                            .padding()
                            .background(VisualEffectView(material: .contentBackground, blendingMode: .withinWindow))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    }
                    
                    // IA FINAL
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Prompt Optimisé")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                            
                            // Menu local pour le "Ton" sans surcharger l'interface globale
                            Picker("", selection: $viewModel.selectedTone) {
                                ForEach(PromptTone.allCases) { tone in
                                    Text(tone.rawValue).tag(tone)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .frame(width: 140)
                            .controlSize(.small)
                            
                            if viewModel.isGeneratingAI {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                        
                        ZStack(alignment: .topTrailing) {
                            ScrollView {
                                Text(viewModel.finalPrompt.isEmpty ? "L'IA rédigera votre prompt final ici..." : viewModel.finalPrompt)
                                    .font(.system(.body, design: .default))
                                    .foregroundColor(viewModel.finalPrompt.isEmpty ? .secondary : .primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(viewModel.finalPrompt.isEmpty ? VisualEffectView(material: .contentBackground, blendingMode: .withinWindow) : VisualEffectView(material: .selection, blendingMode: .withinWindow))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                            
                            // Bannière de téléchargement réseau du modèle Gemma
                            if viewModel.isGeneratingAI, let progress = viewModel.downloadProgress {
                                Text(progress)
                                    .font(.caption2.monospacedDigit())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.9))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                    .padding(8)
                            }
                        }
                    }
                }
                
                // Zone d'Action basse
                if viewModel.isReformulated {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            Task { await viewModel.generatePrompt() }
                        }) {
                            Label("Régénérer", systemImage: "arrow.2.circlepath")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        
                        Button(action: {
                            viewModel.copyToClipboard(viewModel.finalPrompt)
                            showCopyConfirmation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopyConfirmation = false
                            }
                        }) {
                            Label(showCopyConfirmation ? "Copié !" : "Copier le prompt", systemImage: showCopyConfirmation ? "checkmark" : "doc.on.clipboard.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                    }
                    .padding(.top, 5)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
            }
            .padding(24)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 850, minHeight: 650)
        .sheet(isPresented: $viewModel.showOnboarding) {
            OnboardingView(viewModel: viewModel)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url, ["mp3", "m4a", "wav", "aac"].contains(url.pathExtension.lowercased()) {
                    DispatchQueue.main.async {
                        viewModel.processAudioFile(url: url)
                    }
                }
            }
            return true
        }
        .overlay {
            if isTargeted {
                ZStack {
                    Color.blue.opacity(0.15).ignoresSafeArea()
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 4, dash: [10]))
                        .padding(40)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Text("Déposez votre fichier audio ici")
                            .font(.title.bold())
                    }
                }
                .transition(.opacity)
            }
        }
        .alert("Initialisation du Mode Local", isPresented: $viewModel.showInstallationPrompt) {
            Button("Installer MLX & Gemma") {
                Task {
                    await viewModel.installationService.installMlxAutomatically()
                    viewModel.checkMlxStatus()
                }
            }
            Button("Plus tard", role: .cancel) { }
        } message: {
            Text("Pour assurer 100% de confidentialité hors-ligne, NoText nécessite 'mlx-lm'. Le modèle Gemma (2Go) sera préchargé au premier lancement.")
        }
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
