import SwiftUI

struct WriteLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LetterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

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
            EmotionBubble(
                emotion: .calme,
                text: "Écris à toi dans 6 mois. Qu'est-ce que tu veux te dire ?",
                size: .medium,
                style: .emotional
            )

            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(Color.mdOrange)
                Text("Livraison le \(Date().plus6Months.formattedLong)")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.mdTextGray)
            }

            TextEditor(text: $viewModel.content)
                .font(.body)
                .padding(12)
                .textLimit($viewModel.content)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.mdBgSubtle)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.mdBorder, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("Cher futur moi...")
                            .foregroundStyle(Color.mdTextLight)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                Spacer()
                Text("\(viewModel.content.count)/5000 caractères")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mdTextGray)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    viewModel.seal(context: modelContext)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                    Text("Sceller la lettre")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.canSeal ? Color.mdOrange : Color.mdBorder)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .disabled(!viewModel.canSeal)
            .opacity(viewModel.canSeal ? 1 : 0.5)
        }
        .padding(20)
    }

    // MARK: - Sealed

    private var sealedView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.mdOrangeBg)
                    .frame(width: 200, height: 140)

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.mdOrange)
            }

            EmotionBubble(
                emotion: .heureux,
                text: "La lettre est scellée. On se revoit dans 6 mois.",
                size: .large,
                style: .emotional
            )

            Text("Livraison le \(Date().plus6Months.formattedLong)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.mdTextGray)

            Text("Touche pour fermer")
                .font(.system(size: 13))
                .foregroundStyle(Color.mdTextLight)

            Spacer()
        }
        .padding(20)
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
