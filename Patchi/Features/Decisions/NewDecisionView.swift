import SwiftUI

struct NewDecisionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DecisionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        PatchiWithBubble(
                            expression: .thinking,
                            text: "Quelle décision tu as prise ?",
                            patchiSize: .medium,
                            bubbleStyle: .subtle
                        )

                        FormFieldDS(title: "Titre de la décision") {
                            TextField("Ex: Changer de travail", text: $viewModel.title)
                                .dsTextField()
                        }

                        FormFieldDS(title: "Le contexte") {
                            TextEditor(text: $viewModel.context)
                                .frame(minHeight: 80)
                                .dsTextEditor()
                                .textLimit($viewModel.context, max: 2000)
                        }

                        FormFieldDS(title: "Ta prédiction") {
                            TextEditor(text: $viewModel.prediction)
                                .frame(minHeight: 60)
                                .dsTextEditor()
                                .textLimit($viewModel.prediction, max: 2000)
                        }

                        FormFieldDS(title: "Ce que tu as décidé") {
                            TextEditor(text: $viewModel.decision)
                                .frame(minHeight: 60)
                                .dsTextEditor()
                                .textLimit($viewModel.decision, max: 2000)
                        }

                        // Confiance (affiché si prédiction non vide)
                        if !viewModel.prediction.isBlank {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Confiance")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(Color.mdTextBlack)
                                    Spacer()
                                    Text("\(viewModel.confidence) %")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.mdGreen)
                                }

                                Slider(
                                    value: Binding(
                                        get: { Double(viewModel.confidence) },
                                        set: { viewModel.confidence = Int($0) }
                                    ),
                                    in: 50...99,
                                    step: 5
                                )
                                .tint(.mdGreen)

                                Text("À quel point tu es sûr de ta prédiction ?")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.mdTextGray)
                            }
                        }

                        // Importance
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Importance")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.mdTextBlack)
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        viewModel.importance = star
                                        Haptics.light()
                                    } label: {
                                        Image(systemName: star <= viewModel.importance ? "star.fill" : "star")
                                            .font(.title3)
                                            .foregroundStyle(star <= viewModel.importance ? Color.mdYellow : Color.mdBorder)
                                    }
                                    .buttonStyle(SpringPressStyle())
                                }
                            }
                        }

                        // Info rappels
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(Color.mdOrange)
                            Text("Patchi te rappellera dans 30 et 90 jours.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.mdTextGray)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Nouvelle décision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        viewModel.save(context: modelContext)
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .overlay {
                if viewModel.isCompleted {
                    completionOverlay
                }
            }
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 24) {
                PatchiWithBubble(
                    expression: .determined,
                    text: "C'est noté. On se revoit dans 30 jours.",
                    patchiSize: .large
                )

                Text("Touche pour fermer")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .onTapGesture { dismiss() }
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
        }
    }
}

// MARK: - Form Components

private struct FormFieldDS<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.mdTextBlack)
            content
        }
    }
}

extension View {
    func dsTextField() -> some View {
        self
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.mdBgSubtle)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.mdBorder, lineWidth: 1)
            }
    }

    func dsTextEditor() -> some View {
        self
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
    }
}

#Preview {
    NewDecisionView()
        .modelContainer(for: [Decision.self])
}
