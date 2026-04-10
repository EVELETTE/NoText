import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Logo Original Neon Hollow
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 3
                    )
                    .shadow(color: Color.cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                
                Image(systemName: "waveform.badge.mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
                    .foregroundStyle(LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .offset(x: -2) // Ajustement visuel pour le badge
            }
            .frame(width: 120, height: 120)
            .padding(.top, 30)
            
            VStack(spacing: 8) {
                Text("NoText")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Text("Transcription vocale sécurisée et locale.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Text("NoText est un logiciel 100% Open Source.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Intelligence Artificielle propulsée par Gemma,")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("un modèle ouvert mis à disposition par Google.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                if let url = URL(string: "https://checkout.revolut.com/pay/3416e235-8967-497a-8353-3ab929cf35a1") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Offrir un café")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Capsule())
                .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            
            Text("Made with ❤️ by evecorp")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
        }
        .frame(width: 350, height: 450)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
    }
}

// Composant pour l'effet de flou Apple (Glassmorphism natif)
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
