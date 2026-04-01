import SwiftUI

struct NewDecisionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DecisionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Patchi
                    PatchiWithBubble(
                        expression: .thinking,
                        text: "Quelle décision tu as prise ?",
                        patchiSize: .medium,
                        bubbleStyle: .subtle
                    )

                    // Titre
                    FormField(title: "Titre de la décision", placeholder: "Ex: Changer de travail") {
                        TextField("", text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Contexte
                    FormField(title: "Le contexte", placeholder: "Pourquoi cette décision ?") {
                        TextEditor(text: $viewModel.context)
                            .frame(minHeight: 80)
                            .styledTextEditor()
                    }

                    // Prédiction
                    FormField(title: "Ta prédiction", placeholder: "Qu'est-ce que tu penses qu'il va se passer ?") {
                        TextEditor(text: $viewModel.prediction)
                            .frame(minHeight: 60)
                            .styledTextEditor()
                    }

                    // Décision prise
                    FormField(title: "Ce que tu as décidé", placeholder: "Qu'est-ce que tu as choisi ?") {
                        TextEditor(text: $viewModel.decision)
                            .frame(minHeight: 60)
                            .styledTextEditor()
                    }

                    // Importance
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Importance")
                            .font(.headline)
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    viewModel.importance = star
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Image(systemName: star <= viewModel.importance ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundStyle(star <= viewModel.importance ? .orange : Color(.systemGray3))
                                }
                            }
                        }
                    }

                    // Info rappels
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                        Text("Patchi te rappellera dans 30 et 90 jours.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
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

            VStack(spacing: 16) {
                PatchiWithBubble(
                    expression: .determined,
                    text: "C'est noté. On se revoit dans 30 jours.",
                    patchiSize: .large
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    dismiss()
                }
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Form Field

private struct FormField<Content: View>: View {
    let title: String
    let placeholder: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

// MARK: - TextEditor Style

private extension View {
    func styledTextEditor() -> some View {
        self
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            }
    }
}

// MARK: - Preview

#Preview {
    NewDecisionView()
        .modelContainer(for: [Decision.self])
}
