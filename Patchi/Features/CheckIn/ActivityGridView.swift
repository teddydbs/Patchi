import SwiftUI

struct ActivityGridView: View {
    @Binding var selected: [Activity]
    let maxSelection: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("Qu'as-tu fait aujourd'hui ?")
                    .font(.system(size: DS.Font.body, weight: .semibold))
                Spacer()
                Text("\(selected.count)/\(maxSelection)")
                    .font(.system(size: DS.Font.caption, weight: .medium))
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
                RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                    .fill(isSelected ? Color.patchiOrange.opacity(0.15) : Color.dsCard)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                    .strokeBorder(isSelected ? Color.patchiOrange : Color.dsBorder, lineWidth: isSelected ? 2 : 1)
            }
            .foregroundStyle(isSelected ? Color.patchiOrange : Color.dsTextPrimary)
        }
        .buttonStyle(SpringPressStyle())
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
            .background(Color.dsBackground)
        }
    }
    return PreviewWrapper()
}
