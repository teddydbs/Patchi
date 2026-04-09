import SwiftUI

struct EmotionGridView: View {
    @Binding var selected: [Emotion]
    let maxSelection: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Comment tu te sens ?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.mdTextBlack)
                Spacer()
                Text("\(selected.count)/\(maxSelection)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.mdTextGray)
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
                if let imageName = emotion.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: emotion.icon)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                }

                Text(emotion.displayName)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? emotionColor.opacity(0.15) : Color.mdBgSubtle)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(emotionColor, lineWidth: 2)
                }
            }
            .foregroundStyle(isSelected ? emotionColor : Color.mdTextBlack)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.0 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var emotionColor: Color {
        switch emotion {
        case .heureux, .serein, .chanceux, .fiere, .calme, .amoureux:
            .mdGreen
        case .empathique, .confus, .surpris, .nostalgique:
            .mdOrange
        case .embarrasse, .enerve, .stresse, .jaloux:
            Color(red: 1.0, green: 0.35, blue: 0.35) // coral red
        case .triste, .seul:
            .mdPurple
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
            .background(Color.mdBg)
        }
    }
    return PreviewWrapper()
}
