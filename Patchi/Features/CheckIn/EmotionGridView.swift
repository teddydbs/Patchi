import SwiftUI

struct EmotionGridView: View {
    @Binding var selected: [Emotion]
    let maxSelection: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Comment tu te sens ?")
                    .font(.system(size: DS.Font.body, weight: .semibold))
                Spacer()
                Text("\(selected.count)/\(maxSelection)")
                    .font(.system(size: DS.Font.caption, weight: .medium))
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
            Haptics.light()
        } else {
            Haptics.warning()
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
                RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                    .fill(isSelected ? emotionColor.opacity(0.15) : Color.dsCard)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                    .strokeBorder(isSelected ? emotionColor : Color.dsBorder, lineWidth: isSelected ? 2 : 1)
            }
            .foregroundStyle(isSelected ? emotionColor : Color.dsTextPrimary)
        }
        .buttonStyle(SpringPressStyle())
    }

    private var emotionColor: Color {
        switch emotion {
        case .heureux, .beni, .bien, .chanceux, .excite:
            .dsSuccess
        case .confus, .ennuye, .gene, .partage, .nostalgique:
            .accentAmber
        case .stresse, .depasse, .anxieux, .agite, .frustre:
            .moodAngry
        case .enColere:
            .moodAngry
        case .triste, .decu, .epuise, .seul:
            .accentPurple
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: [Emotion] = [.heureux, .stresse]
        var body: some View {
            ScrollView {
                EmotionGridView(selected: $selected)
                    .padding()
            }
            .background(Color.dsBackground)
        }
    }
    return PreviewWrapper()
}
