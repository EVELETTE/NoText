import SwiftUI

struct TipJarSection: View {
    @State private var heartPulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support This Tool")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("If you find this tool helpful, consider buying me a coffee to support its development!")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)

            Spacer()

            Button(action: {
                if let url = URL(string: "https://checkout.revolut.com/pay/3416e235-8967-497a-8353-3ab929cf35a1") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .scaleEffect(heartPulse ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: heartPulse
                        )

                    Text("Buy Me a Coffee")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(#colorLiteral(red: 0.91, green: 0.33, blue: 0.24, alpha: 1)), Color(#colorLiteral(red: 0.58, green: 0.19, blue: 0.81, alpha: 1))],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .onAppear {
                heartPulse = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.91, green: 0.33, blue: 0.24).opacity(0.3),
                            Color(red: 0.58, green: 0.19, blue: 0.81).opacity(0.3),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}
