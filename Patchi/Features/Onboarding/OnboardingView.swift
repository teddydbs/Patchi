import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            // Fond
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: viewModel.currentStep)

            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome {
                    progressBar
                }

                // Contenu
                TabView(selection: Binding(
                    get: { viewModel.currentStep },
                    set: { _ in }
                )) {
                    welcomeStep.tag(OnboardingViewModel.Step.welcome)
                    nameStep.tag(OnboardingViewModel.Step.name)
                    firstQuestionStep.tag(OnboardingViewModel.Step.firstQuestion)
                    reformulationStep.tag(OnboardingViewModel.Step.reformulation)
                    firstSquareStep.tag(OnboardingViewModel.Step.firstSquare)
                    remindersStep.tag(OnboardingViewModel.Step.reminders)
                    trialStep.tag(OnboardingViewModel.Step.trial)
                    accountStep.tag(OnboardingViewModel.Step.account)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
            }
        }
    }

    private var backgroundColor: Color {
        let isDark = colorScheme == .dark
        switch viewModel.currentStep {
        case .welcome: return Color.patchiOrange
        case .name: return isDark ? Color(red: 0.15, green: 0.13, blue: 0.1) : Color(red: 1.0, green: 0.95, blue: 0.88)
        case .firstQuestion: return isDark ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color(red: 0.93, green: 0.93, blue: 0.98)
        case .reformulation: return Color.mood(score: 4)
        case .firstSquare: return isDark ? Color(red: 0.1, green: 0.14, blue: 0.1) : Color(red: 0.95, green: 0.97, blue: 0.95)
        case .reminders: return isDark ? Color(red: 0.1, green: 0.12, blue: 0.18) : Color(red: 0.93, green: 0.95, blue: 1.0)
        case .trial: return isDark ? Color(red: 0.15, green: 0.13, blue: 0.1) : Color(red: 1.0, green: 0.97, blue: 0.93)
        case .account: return isDark ? Color(red: 0.12, green: 0.12, blue: 0.14) : Color(red: 0.96, green: 0.96, blue: 0.98)
        }
    }

    // MARK: - Progress

    private var progressBar: some View {
        let useDark = [.name, .firstSquare, .reminders, .trial, .account]
            .contains(viewModel.currentStep)

        return GeometryReader { geo in
            Capsule()
                .fill(useDark ? Color.black.opacity(0.12) : Color.white.opacity(0.3))
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(useDark ? Color.patchiOrange : Color.white.opacity(0.9))
                        .frame(width: geo.size.width * viewModel.progress, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiView(expression: .waving, size: .hero)

            Text("Salut. Moi c'est Patchi.")
                .font(.custom("CrimsonPro-Italic", size: 28, relativeTo: .title))
                .italic()
                .foregroundStyle(.white)

            Spacer()

            Button {
                viewModel.goNext()
            } label: {
                Text("Salut Patchi !")
                    .font(.headline)
                    .foregroundStyle(Color.patchiOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step 2: Name

    private var nameStep: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiWithBubble(
                expression: .curious,
                text: "Et toi, comment tu t'appelles ?",
                patchiSize: .large,
                bubbleStyle: .standard
            )

            TextField("Ton prénom", text: $viewModel.firstName)
                .font(.title2)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                }
                .padding(.horizontal, 40)

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 3: First Question

    private var firstQuestionStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Aujourd'hui, qu'est-ce qui t'a manqué ?")
                .font(.custom("CrimsonPro-Italic", size: 26, relativeTo: .title))
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            TextEditor(text: $viewModel.firstAnswer)
                .frame(height: 120)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .padding(.horizontal, 32)

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 4: Reformulation

    private var reformulationStep: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiWithBubble(
                expression: .thinking,
                text: viewModel.reformulationText,
                patchiSize: .large,
                bubbleStyle: .emotional
            )

            Spacer()

            Button {
                viewModel.goNext()
            } label: {
                Text("Continuer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step 5: First Square

    private var firstSquareStep: some View {
        VStack(spacing: 32) {
            Spacer()

            // Mini heatmap avec un seul carré allumé
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange)
                        .frame(width: 24, height: 24)

                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(width: 24, height: 24)
                    }
                }
            }

            PatchiWithBubble(
                expression: .happy,
                text: "Jour 1. Reviens demain.",
                patchiSize: .medium,
                bubbleStyle: .standard
            )

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 6: Reminders

    private var remindersStep: some View {
        VStack(spacing: 24) {
            Spacer()

            PatchiWithBubble(
                expression: .calm,
                text: "Je t'enverrai un signe quand c'est l'heure.",
                patchiSize: .medium,
                bubbleStyle: .standard
            )

            VStack(spacing: 20) {
                // Start hour
                VStack(spacing: 8) {
                    HStack {
                        Text("À partir de")
                        Spacer()
                        Text("\(viewModel.notificationStartHour)h00")
                            .fontWeight(.bold)
                    }
                    Slider(value: Binding(
                        get: { Double(viewModel.notificationStartHour) },
                        set: { viewModel.notificationStartHour = Int($0) }
                    ), in: 6...22, step: 1)
                    .tint(.orange)
                }

                // End hour
                VStack(spacing: 8) {
                    HStack {
                        Text("Jusqu'à")
                        Spacer()
                        Text("\(viewModel.notificationEndHour)h00")
                            .fontWeight(.bold)
                    }
                    Slider(value: Binding(
                        get: { Double(viewModel.notificationEndHour) },
                        set: { viewModel.notificationEndHour = Int($0) }
                    ), in: Double(viewModel.notificationStartHour + 1)...23, step: 1)
                    .tint(.orange)
                }

                // Count
                Stepper(
                    "\(viewModel.notificationCount) rappel\(viewModel.notificationCount > 1 ? "s" : "") par jour",
                    value: $viewModel.notificationCount,
                    in: 1...5
                )
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            }
            .padding(.horizontal, 20)

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 7: Trial

    private var trialStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("7 jours pour voir si ça te parle.")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Pas de carte bancaire.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    // TODO: Lancer le trial StoreKit
                    viewModel.goNext()
                } label: {
                    Text("Essayer gratuitement")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.patchiOrange)
                        .cornerRadius(16)
                }

                Button {
                    viewModel.goNext()
                } label: {
                    Text("Continuer sans abonnement")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step 8: Account

    private var accountStep: some View {
        VStack(spacing: 32) {
            Spacer()

            PatchiWithBubble(
                expression: .happy,
                text: "Pour ne rien perdre, crée ton espace.",
                patchiSize: .large,
                bubbleStyle: .standard
            )

            VStack(spacing: 16) {
                AppleSignInButton()
                    .padding(.horizontal, 32)

                Button {
                    // Skip — compléter sans compte
                    viewModel.complete(context: modelContext, appState: appState)
                } label: {
                    Text("Plus tard")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                viewModel.complete(context: modelContext, appState: appState)
            } label: {
                Text("Commencer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.patchiOrange)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Reusable Next Button

    private var nextButton: some View {
        Button {
            viewModel.goNext()
        } label: {
            Text("Suivant")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.canGoNext ? Color.patchiOrange : Color(.systemGray4))
                .cornerRadius(16)
        }
        .disabled(!viewModel.canGoNext)
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
    }
}
