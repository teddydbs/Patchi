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
                Color.mdBg.ignoresSafeArea()

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
        VStack(spacing: 32) {
            Spacer()

            EmotionBubble(
                emotion: .surpris,
                text: verdictType == .j30
                    ? "30 jours. Tu avais vu juste ?"
                    : "90 jours. Le moment de vérité.",
                size: .hero,
                style: .emotional
            )

            Text(decision.title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdTextBlack)
                .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    viewModel.isRevealed = true
                }
            }
        }
    }

    // MARK: - Verdict Form

    private var verdictForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Decision originale
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ta décision")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mdTextGray)
                    Text(decision.decision)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.mdTextBlack)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.mdPurpleBg)
                )

                // Prediction + confiance
                if !decision.prediction.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Ta prédiction")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.mdTextGray)
                            Spacer()
                            if let confidence = decision.confidence {
                                Text("Confiance : \(confidence) %")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.mdOrange)
                            }
                        }
                        Text(decision.prediction)
                            .font(.kokoraBody(15))
                            .italic()
                            .foregroundStyle(Color.mdTextBlack)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.mdOrangeBg)
                    )
                }

                // Verdict buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Le verdict")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mdTextBlack)

                    HStack(spacing: 8) {
                        ForEach(Verdict.allCases) { verdict in
                            VerdictButton(
                                verdict: verdict,
                                isSelected: viewModel.selectedVerdict == verdict
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectedVerdict = verdict
                                }
                                Haptics.medium()
                            }
                        }
                    }
                }

                // Ce qui s'est passe
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ce qui s'est passé")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.mdTextBlack)

                    TextEditor(text: $viewModel.whatHappened)
                        .frame(minHeight: 100)
                        .dsTextEditor()
                }

                // Save button
                Button {
                    viewModel.saveVerdict(decision: decision, verdictType: verdictType)
                } label: {
                    Text("Enregistrer le verdict")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(viewModel.selectedVerdict != nil ? Color.mdGreen : Color.mdTextGray)
                        )
                }
                .disabled(viewModel.selectedVerdict == nil)
                .opacity(viewModel.selectedVerdict != nil ? 1 : 0.5)
            }
            .padding(20)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Image(viewModel.completionEmotion.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)

                Text(viewModel.completionPhrase)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.mdTextBlack)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

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
                    .font(.system(size: 13, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? verdictBgColor : Color.mdBgSubtle)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? verdictColor : Color.mdBorder, lineWidth: isSelected ? 2 : 1)
            }
            .foregroundStyle(isSelected ? verdictColor : Color.mdTextBlack)
        }
        .buttonStyle(SpringPressStyle())
    }

    private var verdictColor: Color {
        switch verdict {
        case .right: .mdGreen
        case .partial: .mdYellow
        case .wrong: Color(red: 0.90, green: 0.30, blue: 0.30)
        }
    }

    private var verdictBgColor: Color {
        switch verdict {
        case .right: .mdGreenBg
        case .partial: .mdYellowBg
        case .wrong: Color(red: 0.90, green: 0.30, blue: 0.30).opacity(0.12)
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
