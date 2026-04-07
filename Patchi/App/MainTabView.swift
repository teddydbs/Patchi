import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var showNewEntryMenu = false
    @State private var showCheckIn = false
    @State private var showNewDecision = false
    @State private var showWriteLetter = false

    var body: some View {
        @Bindable var appState = appState

        ZStack {
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
                    withAnimation(.spring(duration: 0.3)) {
                        showNewEntryMenu = true
                    }
                    appState.selectedTab = .home
                }
            }

            // Menu custom brandé
            if showNewEntryMenu {
                NewEntryMenuOverlay(
                    isPresented: $showNewEntryMenu,
                    onCheckIn: { showCheckIn = true },
                    onDecision: { showNewDecision = true },
                    onLetter: { showWriteLetter = true }
                )
            }
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

// MARK: - Custom New Entry Menu

private struct NewEntryMenuOverlay: View {
    @Binding var isPresented: Bool
    let onCheckIn: () -> Void
    let onDecision: () -> Void
    let onLetter: () -> Void

    var body: some View {
        ZStack {
            // Backdrop opaque flou
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(duration: 0.25)) {
                        isPresented = false
                    }
                }

            // Menu
            VStack(spacing: DS.Spacing.md) {
                Spacer()

                NewEntryMenuItem(
                    icon: "face.smiling.inverse",
                    title: "Mood check-in",
                    subtitle: "Comment tu te sens ?",
                    color: .patchiOrange
                ) {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onCheckIn() }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))

                NewEntryMenuItem(
                    icon: "arrow.triangle.branch",
                    title: "Nouvelle décision",
                    subtitle: "Note une décision importante",
                    color: .accentPurple
                ) {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onDecision() }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))

                NewEntryMenuItem(
                    icon: "envelope.fill",
                    title: "Lettre au futur moi",
                    subtitle: "Écris à toi dans 6 mois",
                    color: .accentAmber
                ) {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onLetter() }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))

                // Bouton fermer
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.dsTextSecondary)
                }
                .padding(.top, DS.Spacing.sm)
                .padding(.bottom, 90)
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }
}

private struct NewEntryMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.medium()
            action()
        }) {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)
                    Text(subtitle)
                        .font(.system(size: DS.Font.caption))
                        .foregroundStyle(Color.dsTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .padding(DS.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .fill(Color.dsCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .clayShadow()
        }
        .buttonStyle(SpringPressStyle())
    }
}
