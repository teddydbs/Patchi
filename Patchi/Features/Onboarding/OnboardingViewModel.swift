import OSLog
import SwiftData
import SwiftUI

@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable {
        case welcome          // 1. Pas sûr de ton humeur ?
        case login            // 2. On fait connaissance ? (Apple / Google / Email)
        case firstQuestion    // 3. Première question
        case reformulation    // 4. Reformulation Patchi
        case firstSquare      // 5. Premier carré heatmap
        case reminders        // 6. Config rappels
        case trial            // 7. Offre d'essai
        case account          // 8. Création compte
    }

    var currentStep: Step = .welcome
    var firstName: String = ""
    var email: String = ""
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
        // login : le passage à l'étape suivante se fait via les boutons d'auth eux-mêmes
        // (Apple / Google / Email), pas via le bouton "Suivant" générique.
        case .login: true
        case .firstQuestion: !firstAnswer.isBlank
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
        // Réutiliser un User existant ou en créer un nouveau
        let existingUsers = (try? context.fetch(FetchDescriptor<User>())) ?? []
        let user: User
        let cleanedName = firstName.trimmed
        let cleanedEmail = email.trimmed
        if let existing = existingUsers.first {
            user = existing
            user.firstName = cleanedName
            if !cleanedEmail.isEmpty { user.email = cleanedEmail }
        } else {
            user = User(
                firstName: cleanedName,
                email: cleanedEmail.isEmpty ? nil : cleanedEmail
            )
            context.insert(user)
        }
        user.onboardingCompleted = true
        user.notificationStartHour = notificationStartHour
        user.notificationEndHour = notificationEndHour
        user.notificationCount = notificationCount

        // Créer la première entrée accountability depuis la réponse onboarding
        if !firstAnswer.isEmpty {
            let entry = AccountabilityEntry(
                missedAction: firstAnswer,
                importance: 3,
                heatmapColor: .orange
            )
            context.insert(entry)
        }

        // Push onboarding_completed = true vers Supabase (permet au même user
        // de skip l'onboarding sur un autre device lors d'un re-login).
        // En cas d'échec réseau on log ; le flag local reste à true et sera
        // resynchronisé via un retry au prochain lancement (cf. TODO).
        Task { @MainActor in
            do {
                try await AuthService.shared.markOnboardingCompleted()
            } catch {
                Logger(subsystem: "com.patchi.app", category: "Onboarding")
                    .error("Failed to sync onboarding_completed to Supabase: \(error.localizedDescription, privacy: .public)")
            }
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
