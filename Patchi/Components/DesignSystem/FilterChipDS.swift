import SwiftUI

struct FilterChipDS: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    var color: Color = .patchiOrange
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: DS.Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, DS.Spacing.md)
            .frame(height: DS.chipHeight)
            .foregroundStyle(isSelected ? Color.white : Color.dsTextSecondary)
            .background {
                Capsule(style: .continuous)
                    .fill(isSelected ? color : Color.dsCard)
            }
            .overlay {
                if !isSelected {
                    Capsule(style: .continuous)
                        .stroke(Color.dsBorder, lineWidth: 1)
                }
            }
        }
        .buttonStyle(SpringPressStyle())
    }
}

// MARK: - Preview

#Preview("FilterChipDS") {
    HStack(spacing: 8) {
        FilterChipDS(label: "Tout", isSelected: true) {}
        FilterChipDS(label: "Courage", icon: "flame", isSelected: false, color: .quoteCourage) {}
        FilterChipDS(label: "Soi", isSelected: false, color: .quoteSoi) {}
    }
    .padding(20)
    .background(Color.dsBackground)
}
