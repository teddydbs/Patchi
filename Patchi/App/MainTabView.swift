import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var showNewEntryMenu = false
    @State private var showCheckIn = false
    @State private var showNewDecision = false
    @State private var showWriteLetter = false

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Aujourd'hui", systemImage: "sun.max.fill")
                }
                .tag(AppTab.home)

            QuotesFeedView()
                .tabItem {
                    Label("Citations", systemImage: "quote.bubble.fill")
                }
                .tag(AppTab.quotes)

            Color.clear
                .tabItem {
                    Label("Nouveau", systemImage: "plus.circle.fill")
                }
                .tag(AppTab.newEntry)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppTab.stats)

            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(AppTab.journal)
        }
        .tint(.orange)
        .onChange(of: appState.selectedTab) { _, newValue in
            if newValue == .newEntry {
                showNewEntryMenu = true
                appState.selectedTab = .home
            }
        }
        .confirmationDialog("Nouvelle entrée", isPresented: $showNewEntryMenu) {
            Button("Mood check-in") {
                showCheckIn = true
            }
            Button("Nouvelle décision") {
                showNewDecision = true
            }
            Button("Lettre au futur moi") {
                showWriteLetter = true
            }
            Button("Annuler", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCheckIn) {
            CheckInView()
        }
        .fullScreenCover(isPresented: $showNewDecision) {
            NewDecisionView()
        }
        .fullScreenCover(isPresented: $showWriteLetter) {
            WriteLetterView()
        }
    }
}
