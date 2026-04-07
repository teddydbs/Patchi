import SwiftUI

struct VerdictView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let decision: Decision
    let verdictType: DecisionReminderType

    @State private var viewModel = VerdictViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()
                BlobBackground(
                    colors: [.accentPurple, .patchiOrange],
                    opacity: 0.1
                )

                if !viewModel.isRevealed {
                    revealAnimation
                } else if viewModel.isSaved {
                    completionView
                } else {
                    verdictForm
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if viewModel.isRevealed && !viewModel.isSaved {
                        Button("Fermer") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Reveal Animation

    private var revealAnimation: some View {
        VStack(spacing: DS.Spacing.xxl) {
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
                .font(.patchiTitle(DS.Font.sectionTitle))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.dsTextPrimary)
                .padding(.horizontal, DS.Spacing.xxl)

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(DS.Animation.screen) {
                    viewModel.isRevealed = true
                }
            }
        }
    }

    // MARK: - Verdict Form

    private var verdictForm: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                PatchiView(expression: .thinking, size: .medium)

                // Decision originale
                ClayCard(tint: .accentPurple) {
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Ta décision")
                            .font(.system(size: DS.Font.caption, weight: .semibold))
                            .foregroundStyle(Color.dsTextSecondary)
                        Text(decision.decision)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.dsTextPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Prediction + confiance
                if !decision.prediction.isEmpty {
                    ClayCard {
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            HStack {
                                Text("Ta prédiction")
                                    .font(.system(size: DS.Font.caption, weight: .semibold))
                                    .foregroundStyle(Color.dsTextSecondary)
                                Spacer()
                                if let confidence = decision.confidence {
                                    Text("Confiance : \(confidence) %")
                                        .font(.system(size: DS.Font.caption, weight: .bold))
                                        .foregroundStyle(Color.patchiOrange)
                                }
                            }
                            Text(decision.prediction)
                                .font(.patchiBody(15))
                                .italic()
                                .foregroundStyle(Color.dsTextPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Verdict buttons
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    Text("Le verdict")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)

                    HStack(spacing: DS.Spacing.sm) {
                        ForEach(Verdict.allCases) { verdict in
                            VerdictButton(
                                verdict: verdict,
                                isSelected: viewModel.selectedVerdict == verdict
                            ) {
                                withAnimation(DS.Animation.micro) {
                                    viewModel.selectedVerdict = verdict
                                }
                                Haptics.medium()
                            }
                        }
                    }
                }

                // Ce qui s'est passe
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Ce qui s'est passé")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)

                    TextEditor(text: $viewModel.whatHappened)
                        .frame(minHeight: 100)
                        .dsTextEditor()
                }

                PillButton(
                    title: "Enregistrer le verdict",
                    style: viewModel.selectedVerdict != nil ? .primary : .secondary
                ) {
                    viewModel.saveVerdict(decision: decision, verdictType: verdictType)
                }
                .disabled(viewModel.selectedVerdict == nil)
                .opacity(viewModel.selectedVerdict != nil ? 1 : 0.5)
            }
            .padding(DS.Spacing.lg)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()

            PatchiWithBubble(
                expression: viewModel.completionExpression,
                text: viewModel.completionPhrase,
                patchiSize: .large,
                bubbleStyle: .emotional
            )

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

// MARK: - Verdict Button

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
                    .font(.system(size: DS.Font.caption, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                    .fill(isSelected ? verdictColor.opacity(0.15) : Color.dsCard)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous)
                    .strokeBorder(isSelected ? verdictColor : Color.dsBorder, lineWidth: isSelected ? 2 : 1)
            }
            .foregroundStyle(isSelected ? verdictColor : Color.dsTextPrimary)
        }
        .buttonStyle(SpringPressStyle())
    }

    private var verdictColor: Color {
        switch verdict {
        case .right: .dsSuccess
        case .partial: .accentAmber
        case .wrong: .dsDestructive
        }
    }
}

#Preview {
    VerdictView(
        decision: Decision(
            title: "Changer de travail",
            context: "Je ne me sens plus a ma place",
            prediction: "Je pense que je serai plus heureux",
            decision: "J'ai donne ma demission",
            importance: 5
        ),
        verdictType: .j30
    )
    .modelContainer(for: [Decision.self])
}
