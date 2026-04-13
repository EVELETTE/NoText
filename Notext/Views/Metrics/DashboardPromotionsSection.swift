import SwiftUI
import AppKit

struct DashboardPromotionsSection: View {
    let licenseState: LicenseViewModel.LicenseState
    @State private var isDismissed = false

    var body: some View {
        Group {
            if !isDismissed {
                instagramFollowBlock
            }
        }
    }

    private var instagramFollowBlock: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.pink)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Follow Our Projects")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Follow us on Instagram to support our development indirectly and discover more awesome tools!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDismissed = true
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Dismiss")
            }

            HStack(spacing: 16) {
                Button(action: {
                    if let url = URL(string: "https://www.instagram.com/ocass_marketplace/") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text("Ocass Marketplace")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(#colorLiteral(red: 0.91, green: 0.33, blue: 0.24, alpha: 1)), Color(#colorLiteral(red: 0.58, green: 0.19, blue: 0.81, alpha: 1))],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)

                Button(action: {
                    if let url = URL(string: "https://www.instagram.com/evecorp.agency/") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                        Text("Evecorp Agency")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(#colorLiteral(red: 0.58, green: 0.19, blue: 0.81, alpha: 1)), Color(#colorLiteral(red: 0.91, green: 0.33, blue: 0.24, alpha: 1))],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.pink.opacity(0.3), lineWidth: 1.5)
        )
    }
}
