import SwiftUI

struct WriteLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LetterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                BlobBackground(colors: [.patchiOrange, .accentAmber], opacity: 0.08)

                if viewModel.isSealed {
                    sealedView
                } else {
                    writeView
                }
            }
            .navigationTitle("Lettre au futur moi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    // MARK: - Write

    private var writeView: some View {
        VStack(spacing: DS.Spacing.xl) {
            PatchiWithBubble(
                expression: .calm,
                text: "Écris à toi dans 6 mois. Qu'est-ce que tu veux te dire ?",
                patchiSize: .medium,
                bubbleStyle: .emotional
            )

            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(Color.patchiOrange)
                Text("Livraison le \(Date().plus6Months.formattedLong)")
                    .font(.system(size: DS.Font.caption))
                    .foregroundStyle(Color.dsTextSecondary)
            }

            TextEditor(text: $viewModel.content)
                .font(.body)
                .padding(DS.Spacing.md)
                .textLimit($viewModel.content)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                        .fill(Color.dsCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                        .stroke(Color.dsBorder, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("Cher futur moi...")
                            .foregroundStyle(Color.dsTextSecondary.opacity(0.5))
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.vertical, DS.Spacing.lg)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                Spacer()
                Text("\(viewModel.content.count)/5000 caractères")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dsTextSecondary)
            }

            Spacer()

            PillButton(
                title: "Sceller la lettre",
                icon: "lock.fill",
                style: viewModel.canSeal ? .primary : .secondary
            ) {
                withAnimation(DS.Animation.screen) {
                    viewModel.seal(context: modelContext)
                }
            }
            .disabled(!viewModel.canSeal)
            .opacity(viewModel.canSeal ? 1 : 0.5)
        }
        .padding(DS.Spacing.lg)
    }

    // MARK: - Sealed

    private var sealedView: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .fill(Color.patchiOrange.opacity(0.15))
                    .frame(width: 200, height: 140)
                    .clayShadow(color: .patchiOrange)

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.patchiOrange)
            }

            PatchiWithBubble(
                expression: .happy,
                text: "La lettre est scellée. On se revoit dans 6 mois.",
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            Text("Livraison le \(Date().plus6Months.formattedLong)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.dsTextSecondary)

            Text("Touche pour fermer")
                .font(.system(size: DS.Font.caption))
                .foregroundStyle(Color.dsTextSecondary.opacity(0.5))

            Spacer()
        }
        .padding(DS.Spacing.lg)
        .onTapGesture { dismiss() }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                dismiss()
            }
        }
    }
}

#Preview {
    WriteLetterView()
        .modelContainer(for: [FutureLetter.self])
}
