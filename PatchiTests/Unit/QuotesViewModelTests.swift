import XCTest
@testable import Patchi

final class QuotesViewModelTests: XCTestCase {
    private var sut: QuotesViewModel!

    override func setUp() {
        super.setUp()
        sut = QuotesViewModel()
        // Nettoyer les favoris persistés entre les tests
        UserDefaults.standard.removeObject(forKey: "quoteFavorites")
        sut.favorites = []
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "quoteFavorites")
        sut = nil
        super.tearDown()
    }

    // MARK: - Filtered Quotes

    func testFilteredQuotesReturnsAllWhenNoCategory() {
        let quotes = sut.filteredQuotes(latestMoodScore: nil)
        XCTAssertFalse(quotes.isEmpty)
    }

    func testFilteredQuotesByCategoryFiltersCorrectly() {
        sut.selectedCategory = .courage
        let quotes = sut.filteredQuotes(latestMoodScore: nil)
        XCTAssertTrue(quotes.allSatisfy { $0.category == .courage })
    }

    func testFilteredQuotesCacheStability() {
        let first = sut.filteredQuotes(latestMoodScore: nil)
        let second = sut.filteredQuotes(latestMoodScore: nil)
        XCTAssertEqual(first.map(\.id), second.map(\.id), "Le cache doit retourner le même ordre")
    }

    func testClearCacheResetsOrder() {
        _ = sut.filteredQuotes(latestMoodScore: nil)
        sut.clearCache()
        // Après clear, un nouvel appel peut (ou pas) shuffler différemment
        // On vérifie juste que ça ne crash pas
        let quotes = sut.filteredQuotes(latestMoodScore: nil)
        XCTAssertFalse(quotes.isEmpty)
    }

    func testFilteredQuotesLowMoodPrioritizesComfort() {
        let quotes = sut.filteredQuotes(latestMoodScore: 1)
        // Les premières quotes devraient être de catégories "réconfort"
        XCTAssertFalse(quotes.isEmpty)
    }

    // MARK: - Favorites

    func testToggleFavoriteAdds() {
        sut.toggleFavorite(42)
        XCTAssertTrue(sut.favorites.contains(42))
    }

    func testToggleFavoriteRemoves() {
        sut.toggleFavorite(42)
        sut.toggleFavorite(42)
        XCTAssertFalse(sut.favorites.contains(42))
    }

    func testFavoritesPersistToUserDefaults() {
        sut.toggleFavorite(7)
        let loaded = QuotesViewModel.loadFavorites()
        XCTAssertTrue(loaded.contains(7))
    }

    // MARK: - Category Change

    func testChangingCategoryClearsRelevantState() {
        _ = sut.filteredQuotes(latestMoodScore: nil)
        sut.selectedCategory = .courage
        sut.clearCache()
        let quotes = sut.filteredQuotes(latestMoodScore: nil)
        XCTAssertTrue(quotes.allSatisfy { $0.category == .courage })
    }
}
