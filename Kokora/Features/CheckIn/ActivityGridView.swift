import SwiftUI

struct ActivityGridView: View {
    @Binding var selected: [Activity]
    let maxSelection: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Qu'as-tu fait aujourd'hui ?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.mdTextBlack)
                Spacer()
                Text("\(selected.count)/\(maxSelection)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.mdTextGray)
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
            Haptics.light()
        } else {
            Haptics.warning()
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
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)

                Text(activity.displayName)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.mdGreen.opacity(0.15) : Color.mdBgSubtle)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.mdGreen, lineWidth: 2)
                }
            }
            .foregroundStyle(isSelected ? Color.mdGreen : Color.mdTextBlack)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: [Activity] = [.sport, .travail]
        var body: some View {
            ScrollView {
                ActivityGridView(selected: $selected)
                    .padding()
            }
            .background(Color.mdBg)
        }
    }
    return PreviewWrapper()
}
