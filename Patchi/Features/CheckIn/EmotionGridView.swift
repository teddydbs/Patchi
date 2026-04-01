import SwiftUI

struct EmotionGridView: View {
    @Binding var selected: [Emotion]
    let maxSelection: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Comment tu te sens ?")
                    .font(.headline)
                Spacer()
                Text("\(selected.count)/\(maxSelection)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Emotion.allCases) { emotion in
                    EmotionCell(
                        emotion: emotion,
                        isSelected: selected.contains(emotion),
                        action: { toggle(emotion) }
                    )
                }
            }
        }
    }

    private func toggle(_ emotion: Emotion) {
        if let index = selected.firstIndex(of: emotion) {
            selected.remove(at: index)
        } else if selected.count < maxSelection {
            selected.append(emotion)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}

private struct EmotionCell: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: emotion.icon)
                    .font(.title3)
                    .frame(width: 32, height: 32)

                Text(emotion.displayName)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? emotionColor.opacity(0.15) : Color(.systemGray6))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? emotionColor : .clear, lineWidth: 2)
            }
            .foregroundStyle(isSelected ? emotionColor : .primary)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }

    private var emotionColor: Color {
        switch emotion {
        case .heureux, .beni, .bien, .chanceux, .excite:
            .green
        case .confus, .ennuye, .gene, .partage, .nostalgique:
            .orange
        case .stresse, .depasse, .anxieux, .agite, .frustre:
            .red
        case .enColere:
            .red
        case .triste, .decu, .epuise, .seul:
            .blue
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: [Emotion] = [.heureux, .stresse]
        var body: some View {
            ScrollView {
                EmotionGridView(selected: $selected)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}
