import SwiftUI

struct ClayCard<Content: View>: View {
    var tint: Color? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(DS.Spacing.lg)
            .background {
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .fill(tint?.opacity(0.08) ?? Color.dsCard.opacity(1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .clayShadow(color: tint ?? .black)
    }
}

// MARK: - Tappable variant

struct TappableClayCard<Content: View>: View {
    var tint: Color? = nil
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            ClayCard(tint: tint) {
                content()
            }
        }
        .buttonStyle(SpringPressStyle())
    }
}

// MARK: - Preview

#Preview("ClayCard") {
    VStack(spacing: 20) {
        ClayCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card neutre")
                    .font(.headline)
                Text("Avec ombre clay et stroke interieur")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        ClayCard(tint: .patchiOrange) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Card tintee orange")
                    .font(.headline)
                Spacer()
            }
        }

        TappableClayCard(tint: .accentPurple) {
            // action
        } content: {
            Text("Tappable card")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
    }
    .padding(20)
    .background(Color.dsBackground)
}
