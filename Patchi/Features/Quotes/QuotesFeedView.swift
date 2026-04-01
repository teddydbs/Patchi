import SwiftUI
import SwiftData

struct QuotesFeedView: View {
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @State private var selectedCategory: QuoteCategory?
    @State private var favorites: Set<Int> = QuotesFeedView.loadFavorites()
    @State private var currentIndex: Int = 0
    @State private var cachedQuotes: [Quote]?

    var body: some View {
        ZStack {
            // Feed swipeable plein écran
            TabView(selection: $currentIndex) {
                ForEach(Array(filteredQuotes.enumerated()), id: \.element.id) { index, quote in
                    QuoteCardView(
                        quote: quote,
                        isFavorite: favorites.contains(quote.id),
                        onToggleFavorite: { toggleFavorite(quote.id) },
                        onShare: { shareQuote(quote) }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Filtres en haut
            VStack {
                filterBar
                Spacer()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "Tout", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                    cachedQuotes = nil
                }

                ForEach(QuoteCategory.allCases) { category in
                    FilterChip(
                        label: category.displayName,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = category
                        cachedQuotes = nil
                    }
                }

                FilterChip(label: "♥ Favoris", isSelected: false) {
                    // TODO: Vue favoris
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .safeAreaPadding(.top)
    }

    // MARK: - Data

    private var filteredQuotes: [Quote] {
        // Filtre par catégorie : pas de cache (liste courte)
        if let category = selectedCategory {
            return allQuotes.filter { $0.category == category }
        }

        // Mode "tout" : utiliser le cache pour ne pas re-shuffler
        if let cached = cachedQuotes {
            return cached
        }

        var quotes: [Quote]
        if let latestMood = checkIns.first?.moodScore {
            let preferredCategories = latestMood <= 2
                ? QuoteCategory.forLowMood()
                : QuoteCategory.forHighMood()
            let preferred = allQuotes.filter { preferredCategories.contains($0.category) }
            let others = allQuotes.filter { !preferredCategories.contains($0.category) }
            quotes = preferred.shuffled() + others.shuffled()
        } else {
            quotes = allQuotes.shuffled()
        }

        DispatchQueue.main.async { cachedQuotes = quotes }
        return quotes
    }

    private func toggleFavorite(_ id: Int) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        Self.saveFavorites(favorites)
    }

    private func shareQuote(_ quote: Quote) {
        let text = "\"\(quote.text)\"\n— \(quote.author)\n\nvia Patchi"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }

    // MARK: - Persistence

    private static let favoritesKey = "quoteFavorites"

    static func loadFavorites() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? []
        return Set(array)
    }

    private static func saveFavorites(_ favorites: Set<Int>) {
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }
}

// MARK: - Quote Card (plein écran)

private struct QuoteCardView: View {
    let quote: Quote
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onShare: () -> Void

    var body: some View {
        ZStack {
            // Fond doux avec teinte de la catégorie (cohérent avec le reste de l'app)
            LinearGradient(
                colors: [
                    quote.category.color.opacity(0.15),
                    quote.category.color.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(Color(.systemBackground))
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Citation
                Text(quote.text)
                    .font(.custom("CrimsonPro-Italic", size: 26, relativeTo: .title))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 32)

                // Auteur
                Text("— \(quote.author)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                // Actions
                HStack(spacing: 32) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isFavorite ? .red : quote.category.color)
                    }

                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundStyle(quote.category.color)
                    }
                }
                .padding(.bottom, 60)
            }

            // Catégorie en bas à gauche
            VStack {
                Spacer()
                HStack {
                    Text(quote.category.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(quote.category.color.opacity(0.15))
                        .cornerRadius(8)
                        .foregroundStyle(quote.category.color)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    var color: Color = .patchiOrange
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule().fill(isSelected ? color : Color(.systemGray5))
                }
                .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}
