import SwiftUI
import SwiftData

@main
struct PatchiApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
        .modelContainer(for: [
            User.self,
            CheckIn.self,
            AccountabilityEntry.self,
            Decision.self,
            FutureLetter.self
        ])
    }
}
