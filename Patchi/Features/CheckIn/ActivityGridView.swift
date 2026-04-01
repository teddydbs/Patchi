import SwiftUI

struct ActivityGridView: View {
    @Binding var selected: [Activity]
    let maxSelection: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Qu'as-tu fait aujourd'hui ?")
                    .font(.headline)
                Spacer()
                Text("\(selected.count)/\(maxSelection)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Activity.allCases) { activity in
                    ActivityCell(
                        activity: activity,
                        isSelected: selected.contains(activity),
                        action: { toggle(activity) }
                    )
                }
            }
        }
    }

    private func toggle(_ activity: Activity) {
        if let index = selected.firstIndex(of: activity) {
            selected.remove(at: index)
        } else if selected.count < maxSelection {
            selected.append(activity)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}

private struct ActivityCell: View {
    let activity: Activity
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: activity.icon)
                    .font(.title3)
                    .frame(width: 32, height: 32)

                Text(activity.displayName)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.patchiOrange.opacity(0.15) : Color(.systemGray6))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.patchiOrange : .clear, lineWidth: 2)
            }
            .foregroundStyle(isSelected ? Color.patchiOrange : .primary)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: [Activity] = [.sport, .travail]
        var body: some View {
            ScrollView {
                ActivityGridView(selected: $selected)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}
