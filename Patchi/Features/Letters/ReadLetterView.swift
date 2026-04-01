import SwiftUI

struct ReadLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let letter: FutureLetter
    @State private var viewModel = LetterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 1.0, green: 0.97, blue: 0.93)
                    .ignoresSafeArea()

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
                // Marquer comme livrée
                letter.isDelivered = true
                viewModel.openLetter()
            }
        }
    }

    // MARK: - Enveloppe (avant ouverture)

    private var envelopeView: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiWithBubble(
                expression: .excited,
                text: "La lettre est arrivée. Elle t'attendait.",
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            // Enveloppe animée
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.patchiOrange.opacity(0.15))
                    .frame(width: 220, height: 150)

                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                    .scaleEffect(viewModel.isOpening ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatCount(2),
                        value: viewModel.isOpening
                    )
            }

            Text("Écrite le \(letter.writtenAt.formattedLong)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(20)
    }

    // MARK: - Contenu de la lettre

    private var letterContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date d'écriture
                Text("Le \(letter.writtenAt.formattedLong), tu avais écrit :")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Contenu de la lettre
                Text(letter.content)
                    .font(.custom("CrimsonPro-Italic", size: 18, relativeTo: .body))
                    .italic()
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    }

                Divider()

                // Répondre
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tu veux répondre ?")
                        .font(.headline)

                    Text("Ta réponse deviendra une nouvelle lettre pour dans 6 mois.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $viewModel.replyText)
                        .frame(minHeight: 100)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color(.systemGray4), lineWidth: 1)
                        }

                    Button {
                        viewModel.reply(to: letter, context: modelContext)
                        dismiss()
                    } label: {
                        Label("Envoyer la réponse", systemImage: "paperplane.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                viewModel.replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color(.systemGray4)
                                    : Color.patchiOrange
                            )
                            .cornerRadius(14)
                    }
                    .disabled(viewModel.replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Preview

#Preview {
    ReadLetterView(letter: FutureLetter(content: "Cher futur moi, j'espère que tu vas bien. En ce moment je traverse une période de doute mais je sais que ça va passer. Continue à croire en toi."))
        .modelContainer(for: [FutureLetter.self])
}
