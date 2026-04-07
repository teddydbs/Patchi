import SwiftUI

struct NewDecisionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DecisionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DS.Spacing.xl) {
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
                        if !viewModel.prediction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                                HStack {
                                    Text("Confiance")
                                        .font(.system(size: DS.Font.body, weight: .semibold))
                                        .foregroundStyle(Color.dsTextPrimary)
                                    Spacer()
                                    Text("\(viewModel.confidence) %")
                                        .font(.system(size: DS.Font.body, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.patchiOrange)
                                }

                                Slider(
                                    value: Binding(
                                        get: { Double(viewModel.confidence) },
                                        set: { viewModel.confidence = Int($0) }
                                    ),
                                    in: 50...99,
                                    step: 5
                                )
                                .tint(.patchiOrange)

                                Text("À quel point tu es sûr de ta prédiction ?")
                                    .font(.system(size: DS.Font.caption))
                                    .foregroundStyle(Color.dsTextSecondary)
                            }
                        }

                        // Importance
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Importance")
                                .font(.system(size: DS.Font.body, weight: .semibold))
                                .foregroundStyle(Color.dsTextPrimary)
                            HStack(spacing: DS.Spacing.sm) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        viewModel.importance = star
                                        Haptics.light()
                                    } label: {
                                        Image(systemName: star <= viewModel.importance ? "star.fill" : "star")
                                            .font(.title3)
                                            .foregroundStyle(star <= viewModel.importance ? Color.accentAmber : Color.dsBorder)
                                    }
                                    .buttonStyle(SpringPressStyle())
                                }
                            }
                        }

                        // Info rappels
                        HStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(Color.patchiOrange)
                            Text("Patchi te rappellera dans 30 et 90 jours.")
                                .font(.system(size: DS.Font.caption))
                                .foregroundStyle(Color.dsTextSecondary)
                        }
                    }
                    .padding(DS.Spacing.lg)
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

            VStack(spacing: DS.Spacing.xl) {
                PatchiWithBubble(
                    expression: .determined,
                    text: "C'est noté. On se revoit dans 30 jours.",
                    patchiSize: .large
                )

                Text("Touche pour fermer")
                    .font(.system(size: DS.Font.caption))
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
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .font(.system(size: DS.Font.body, weight: .semibold))
                .foregroundStyle(Color.dsTextPrimary)
            content
        }
    }
}

extension View {
    func dsTextField() -> some View {
        self
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                    .fill(Color.dsCard)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                    .stroke(Color.dsBorder, lineWidth: 1)
            }
    }

    func dsTextEditor() -> some View {
        self
            .padding(DS.Spacing.sm)
            .scrollContentBackground(.hidden)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                    .fill(Color.dsCard)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous)
                    .stroke(Color.dsBorder, lineWidth: 1)
            }
    }
}

#Preview {
    NewDecisionView()
        .modelContainer(for: [Decision.self])
}
