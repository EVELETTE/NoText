import SwiftUI

struct InstagramProjectsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Instagram icon
            HStack(spacing: 10) {
                instagramLogoIcon
                    .font(.system(size: 22))

                Text("Follow Us on Instagram")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Text("Follow us to support our projects indirectly!")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)

            // Project cards
            VStack(spacing: 10) {
                instagramCard(
                    logoName: "OcassLogo",
                    title: "Ocass Marketplace",
                    url: "https://www.instagram.com/ocass_marketplace/"
                )

                instagramCard(
                    logoName: "EvecorpLogo",
                    title: "Evecorp Agency",
                    url: "https://www.instagram.com/evecorp.agency/"
                )
            }
        }
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
                            Color(red: 0.98, green: 0.38, blue: 0.14).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }

    private var instagramLogoIcon: some View {
        Image("InstagramLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
    }

    @ViewBuilder
    private func instagramCard(logoName: String, title: String, url: String) -> some View {
        Button(action: {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                // Brand logo
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                // Text content
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                // Arrow indicator
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
