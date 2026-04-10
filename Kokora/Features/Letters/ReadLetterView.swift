import SwiftUI

struct ReadLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let letter: FutureLetter
    @State private var viewModel = LetterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

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
        VStack(spacing: 32) {
            Spacer()

            EmotionBubble(
                emotion: .nostalgique,
                text: "La lettre est arrivée. Elle t'attendait.",
                size: .large,
                style: .emotional
            )

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.mdOrangeBg)
                    .frame(width: 220, height: 150)

                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.mdOrange)
                    .scaleEffect(viewModel.isOpening ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatCount(2),
                        value: viewModel.isOpening
                    )
            }

            Text("Écrite le \(letter.writtenAt.formattedLong)")
                .font(.system(size: 13))
                .foregroundStyle(Color.mdTextGray)

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Letter Content

    private var letterContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Le \(letter.writtenAt.formattedLong), tu avais écrit :")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.mdTextGray)

                // Letter card
                VStack {
                    Text(letter.content)
                        .font(.kokoraBody(18))
                        .italic()
                        .foregroundStyle(Color.mdTextBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.mdOrangeBg)
                )

                // Reply section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tu veux répondre ?")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mdTextBlack)

                    Text("Ta réponse deviendra une nouvelle lettre pour dans 6 mois.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mdTextGray)

                    TextEditor(text: $viewModel.replyText)
                        .frame(minHeight: 100)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.mdBgSubtle)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.mdBorder, lineWidth: 1)
                        }

                    Button {
                        viewModel.reply(to: letter, context: modelContext)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Envoyer la réponse")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canReply ? Color.mdGreen : Color.mdBorder)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .disabled(!canReply)
                    .opacity(canReply ? 1 : 0.5)
                }
            }
            .padding(20)
        }
    }

    private var canReply: Bool { !viewModel.replyText.isBlank }
}

#Preview {
    ReadLetterView(letter: FutureLetter(content: "Cher futur moi, j'espere que tu vas bien."))
        .modelContainer(for: [FutureLetter.self])
}
