import SwiftUI

struct ReadLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let letter: FutureLetter
    @State private var viewModel = LetterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                BlobBackground(colors: [.patchiOrange, .accentAmber], opacity: 0.08)

                if !viewModel.isOpened {
                    envelopeView
                } else {
                    letterContentView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onAppear {
                letter.isDelivered = true
                viewModel.openLetter()
            }
        }
    }

    // MARK: - Envelope

    private var envelopeView: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()

            PatchiWithBubble(
                expression: .excited,
                text: "La lettre est arrivée. Elle t'attendait.",
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .fill(Color.patchiOrange.opacity(0.15))
                    .frame(width: 220, height: 150)
                    .clayShadow(color: .patchiOrange)

                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.patchiOrange)
                    .scaleEffect(viewModel.isOpening ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatCount(2),
                        value: viewModel.isOpening
                    )
            }

            Text("Écrite le \(letter.writtenAt.formattedLong)")
                .font(.system(size: DS.Font.caption))
                .foregroundStyle(Color.dsTextSecondary)

            Spacer()
        }
        .padding(DS.Spacing.lg)
    }

    // MARK: - Letter Content

    private var letterContentView: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                Text("Le \(letter.writtenAt.formattedLong), tu avais écrit :")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.dsTextSecondary)

                ClayCard(tint: .patchiOrange) {
                    Text(letter.content)
                        .font(.patchiBody(18))
                        .italic()
                        .foregroundStyle(Color.dsTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Reply section
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    Text("Tu veux répondre ?")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)

                    Text("Ta réponse deviendra une nouvelle lettre pour dans 6 mois.")
                        .font(.system(size: DS.Font.caption))
                        .foregroundStyle(Color.dsTextSecondary)

                    TextEditor(text: $viewModel.replyText)
                        .frame(minHeight: 100)
                        .dsTextEditor()

                    PillButton(
                        title: "Envoyer la réponse",
                        icon: "paperplane.fill",
                        style: canReply ? .primary : .secondary
                    ) {
                        viewModel.reply(to: letter, context: modelContext)
                        dismiss()
                    }
                    .disabled(!canReply)
                    .opacity(canReply ? 1 : 0.5)
                }
            }
            .padding(DS.Spacing.lg)
        }
    }

    private var canReply: Bool {
        !viewModel.replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    ReadLetterView(letter: FutureLetter(content: "Cher futur moi, j'espere que tu vas bien."))
        .modelContainer(for: [FutureLetter.self])
}
