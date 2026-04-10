import SwiftUI

@Observable
final class AppState {
    var isOnboardingCompleted: Bool = false
    var isPremium: Bool = false
    var isUnlocked: Bool = false
    var selectedTab: AppTab = .home
    var currentMoodColor: Color = .clear

    /// Date demandée par un autre écran (ex: HomeView calendar strip).
    /// JournalView l'observe et filtre automatiquement quand non-nil.
    var journalDate: Date?
}

enum AppTab: Int, CaseIterable {
    case home
    case quotes
    case newEntry
    case stats
    case journal
}
