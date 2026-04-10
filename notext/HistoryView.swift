import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager = HistoryManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Historique")
                    .font(.title2.bold())
                Spacer()
                Button(action: { historyManager.clearHistory() }) {
                    Text("Tout effacer")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 10)
            }
            .padding()
            .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
            
            Divider()
            
            if historyManager.items.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("Aucun historique pour le moment")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(historyManager.items) { item in
                        HistoryRow(item: item)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .contextMenu {
                                Button("Copier le Prompt") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.finalPrompt, forType: .string)
                                }
                                Button("Supprimer", role: .destructive) {
                                    historyManager.deleteItem(item)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 500, height: 600)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
    }
}

struct HistoryRow: View {
    let item: TranscriptionItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.date, style: .time)
                    .font(.caption.bold())
                    .foregroundColor(.cyan)
                
                Text(item.tone)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(item.finalPrompt, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Copier le Prompt")
            }
            
            Text(item.originalText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 2)
            
            if isExpanded {
                Divider()
                Text(item.finalPrompt)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Button(isExpanded ? "Réduire" : "Voir le prompt") {
                withAnimation { isExpanded.toggle() }
            }
            .buttonStyle(.plain)
            .font(.caption2.bold())
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.1), lineWidth: 1))
    }
}
