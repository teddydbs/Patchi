import SwiftUI

@Observable
final class QuotesViewModel {
    // MARK: - State

    var selectedCategory: QuoteCategory?
    var favorites: Set<Int> = {
        let array = UserDefaults.standard.array(forKey: "quoteFavorites") as? [Int] ?? []
        return Set(array)
    }()
    var currentIndex: Int = 0

    // MARK: - Cache

    private var cachedQuotes: [Quote]?

    // MARK: - Filtered Quotes

    func filteredQuotes(latestMoodScore: Int?) -> [Quote] {
        if let category = selectedCategory {
            return allQuotes.filter { $0.category == category }
        }

        if let cached = cachedQuotes {
            return cached
        }

        var quotes: [Quote]
        if let latestMood = latestMoodScore {
            let preferredCategories = latestMood <= 2
                ? QuoteCategory.forLowMood()
                : QuoteCategory.forHighMood()
            let preferred = allQuotes.filter { preferredCategories.contains($0.category) }
            let others = allQuotes.filter { !preferredCategories.contains($0.category) }
            quotes = preferred.shuffled() + others.shuffled()
        } else {
            quotes = allQuotes.shuffled()
        }

        cachedQuotes = quotes
        return quotes
    }

    func clearCache() {
        cachedQuotes = nil
    }

    // MARK: - Favorites

    func toggleFavorite(_ id: Int) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        Self.saveFavorites(favorites)
    }

    // MARK: - Share

    func shareQuote(_ quote: Quote) {
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
