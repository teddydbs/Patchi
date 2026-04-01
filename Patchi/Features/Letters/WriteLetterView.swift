import SwiftUI

struct WriteLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LetterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Fond doux
                Color(red: 1.0, green: 0.97, blue: 0.93)
                    .ignoresSafeArea()

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
        VStack(spacing: 24) {
            PatchiWithBubble(
                expression: .calm,
                text: "Écris à toi dans 6 mois. Qu'est-ce que tu veux te dire ?",
                patchiSize: .medium,
                bubbleStyle: .emotional
            )

            // Date de livraison
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(.orange)
                Text("Livraison le \(Date().plus6Months.formattedLong)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Zone d'écriture
            TextEditor(text: $viewModel.content)
                .font(.body)
                .padding(12)
                .frame(minHeight: 200)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("Cher futur moi...")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }

            // Compteur
            HStack {
                Spacer()
                Text("\(viewModel.content.count) caractères")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Bouton sceller
            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    viewModel.seal(context: modelContext)
                }
            } label: {
                Label("Sceller la lettre", systemImage: "lock.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.canSeal ? Color.patchiOrange : Color(.systemGray4))
                    .cornerRadius(16)
            }
            .disabled(!viewModel.canSeal)
        }
        .padding(20)
    }

    // MARK: - Sealed

    private var sealedView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Enveloppe scellée
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.patchiOrange.opacity(0.15))
                    .frame(width: 200, height: 140)

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
            }

            PatchiWithBubble(
                expression: .happy,
                text: "La lettre est scellée. On se revoit dans 6 mois.",
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            Text("Livraison le \(Date().plus6Months.formattedLong)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WriteLetterView()
        .modelContainer(for: [FutureLetter.self])
}
