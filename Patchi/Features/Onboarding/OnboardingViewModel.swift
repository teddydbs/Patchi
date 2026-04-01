import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable {
        case welcome          // 1. Patchi apparaît
        case name             // 2. Prénom
        case firstQuestion    // 3. Première question
        case reformulation    // 4. Reformulation Patchi
        case firstSquare      // 5. Premier carré heatmap
        case reminders        // 6. Config rappels
        case trial            // 7. Offre d'essai
        case account          // 8. Création compte
    }

    var currentStep: Step = .welcome
    var firstName: String = ""
    var firstAnswer: String = ""
    var reformulationText: String = ""
    var notificationStartHour: Int = 19
    var notificationEndHour: Int = 22
    var notificationCount: Int = 1

    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(Step.allCases.count)
    }

    var canGoNext: Bool {
        switch currentStep {
        case .welcome: true
        case .name: !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .firstQuestion: !firstAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .reformulation: true
        case .firstSquare: true
        case .reminders: true
        case .trial: true
        case .account: true
        }
    }

    func goNext() {
        guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }

        if currentStep == .firstQuestion {
            reformulationText = ReformulationService.shared.reformulate(firstAnswer)
        }

        Haptics.selection()

        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = next
        }
    }

    func complete(context: ModelContext, appState: AppState) {
        Haptics.success()
        // Créer le User
        let user = User(firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines))
        user.onboardingCompleted = true
        user.notificationStartHour = notificationStartHour
        user.notificationEndHour = notificationEndHour
        user.notificationCount = notificationCount
        context.insert(user)

        // Créer la première entrée accountability depuis la réponse onboarding
        if !firstAnswer.isEmpty {
            let entry = AccountabilityEntry(
                missedAction: firstAnswer,
                importance: 3,
                heatmapColor: .orange
            )
            context.insert(entry)
        }

        // Scheduler les notifications
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted {
                NotificationService.shared.scheduleEveningNotifications(
                    startHour: notificationStartHour,
                    endHour: notificationEndHour,
                    count: notificationCount
                )
                NotificationService.shared.scheduleSundayRitual()
            }
        }

        // Mettre à jour l'app state
        appState.isOnboardingCompleted = true
    }
}
