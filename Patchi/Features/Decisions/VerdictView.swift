import SwiftUI

struct VerdictView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let decision: Decision
    let verdictType: DecisionReminderType

    @State private var selectedVerdict: Verdict?
    @State private var whatHappened: String = ""
    @State private var isRevealed = false
    @State private var isSaved = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fond
                Color(red: 0.96, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()

                if !isRevealed {
                    revealAnimation
                } else if isSaved {
                    completionView
                } else {
                    verdictForm
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isRevealed && !isSaved {
                        Button("Fermer") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Reveal Animation

    private var revealAnimation: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiWithBubble(
                expression: .determined,
                text: verdictType == .j30
                    ? "30 jours. Tu avais vu juste ?"
                    : "90 jours. Le moment de vérité.",
                patchiSize: .hero,
                bubbleStyle: .emotional
            )

            Text(decision.title)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isRevealed = true
                }
            }
        }
    }

    // MARK: - Verdict Form

    private var verdictForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Patchi
                PatchiView(expression: .thinking, size: .medium)

                // Rappel de la décision originale
                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel(text: "Ta décision")
                    Text(decision.decision)
                        .font(.subheadline)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }

                // Rappel de la prédiction
                if !decision.prediction.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(text: "Ta prédiction")
                        Text(decision.prediction)
                            .font(.subheadline)
                            .italic()
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                }

                Divider()

                // Verdict
                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel(text: "Le verdict")

                    HStack(spacing: 10) {
                        ForEach(Verdict.allCases) { verdict in
                            VerdictButton(
                                verdict: verdict,
                                isSelected: selectedVerdict == verdict
                            ) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedVerdict = verdict
                                }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                }

                // Ce qui s'est passé
                VStack(alignment: .leading, spacing: 12) {
                    SectionLabel(text: "Ce qui s'est passé")

                    TextEditor(text: $whatHappened)
                        .frame(minHeight: 100)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color(.systemGray4), lineWidth: 1)
                        }
                }

                // Bouton enregistrer
                Button {
                    saveVerdict()
                } label: {
                    Text("Enregistrer le verdict")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedVerdict != nil ? Color.purple : Color(.systemGray4))
                        .cornerRadius(16)
                }
                .disabled(selectedVerdict == nil)
            }
            .padding(20)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiWithBubble(
                expression: completionExpression,
                text: completionPhrase,
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            Spacer()
        }
        .padding(20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func saveVerdict() {
        guard let verdict = selectedVerdict else { return }
        let text = whatHappened.trimmingCharacters(in: .whitespacesAndNewlines)

        if verdictType == .j30 {
            decision.verdict30 = verdict
            decision.whatHappened30 = text.isEmpty ? nil : text
            decision.status = .reviewed30
        } else {
            decision.verdict90 = verdict
            decision.whatHappened90 = text.isEmpty ? nil : text
            decision.status = .reviewed90
        }

        withAnimation {
            isSaved = true
        }
    }

    private var completionExpression: PatchiExpression {
        switch selectedVerdict {
        case .right: .celebrating
        case .partial: .thinking
        case .wrong: .comforting
        case nil: .neutral
        }
    }

    private var completionPhrase: String {
        switch selectedVerdict {
        case .right: "Tu avais vu juste. Fais-toi confiance."
        case .partial: "Pas tout à fait, mais tu apprends. C'est ça qui compte."
        case .wrong: "Hé. C'est ok. Chaque erreur est une leçon."
        case nil: "C'est noté."
        }
    }
}

// MARK: - Components

private struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

private struct VerdictButton: View {
    let verdict: Verdict
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: verdict.icon)
                    .font(.title2)
                Text(verdict.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? verdictColor.opacity(0.15) : Color(.systemGray6))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? verdictColor : .clear, lineWidth: 2)
            }
            .foregroundStyle(isSelected ? verdictColor : .primary)
        }
        .buttonStyle(.plain)
    }

    private var verdictColor: Color {
        switch verdict {
        case .right: .green
        case .partial: .orange
        case .wrong: .red
        }
    }
}

// MARK: - Preview

#Preview {
    VerdictView(
        decision: Decision(
            title: "Changer de travail",
            context: "Je ne me sens plus à ma place",
            prediction: "Je pense que je serai plus heureux",
            decision: "J'ai donné ma démission",
            importance: 5
        ),
        verdictType: .j30
    )
    .modelContainer(for: [Decision.self])
}
