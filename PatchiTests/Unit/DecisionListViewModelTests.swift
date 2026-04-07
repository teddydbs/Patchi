import XCTest
@testable import Patchi

final class DecisionListViewModelTests: XCTestCase {
    private var sut: DecisionListViewModel!

    override func setUp() {
        super.setUp()
        sut = DecisionListViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Filtering

    func testFilteredDecisionsNoFilterReturnsAll() {
        let decisions = [
            Decision(title: "A", context: "", prediction: "", decision: ""),
            Decision(title: "B", context: "", prediction: "", decision: ""),
        ]
        let result = sut.filteredDecisions(from: decisions)
        XCTAssertEqual(result.count, 2)
    }

    func testFilteredDecisionsByPending() {
        let d1 = Decision(title: "Pending", context: "", prediction: "", decision: "")
        let d2 = Decision(title: "Reviewed", context: "", prediction: "", decision: "")
        d2.status = .reviewed30

        sut.selectedFilter = .pending
        let result = sut.filteredDecisions(from: [d1, d2])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Pending")
    }

    func testFilteredDecisionsByReviewed30() {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        let d2 = Decision(title: "B", context: "", prediction: "", decision: "")
        d2.status = .reviewed30

        sut.selectedFilter = .reviewed30
        let result = sut.filteredDecisions(from: [d1, d2])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "B")
    }

    func testFilteredDecisionsEmptyWhenNoMatch() {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        sut.selectedFilter = .reviewed90
        let result = sut.filteredDecisions(from: [d1])
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Handle Verdict Tap

    func testHandleVerdictTapPendingPastJ30() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        // Forcer reviewAt30 dans le passé
        decision.reviewAt30 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        sut.handleVerdictTap(for: decision)

        XCTAssertTrue(sut.showVerdict)
        XCTAssertEqual(sut.verdictType, .j30)
        XCTAssertEqual(sut.selectedDecision?.title, "Test")
    }

    func testHandleVerdictTapReviewed30PastJ90() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        decision.status = .reviewed30
        decision.reviewAt90 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        sut.handleVerdictTap(for: decision)

        XCTAssertTrue(sut.showVerdict)
        XCTAssertEqual(sut.verdictType, .j90)
    }

    func testHandleVerdictTapPendingNotYetJ30() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        // reviewAt30 est dans le futur par défaut (30 jours)

        sut.handleVerdictTap(for: decision)

        XCTAssertFalse(sut.showVerdict, "Ne doit pas ouvrir le verdict si J+30 pas atteint")
    }

    func testHandleVerdictTapAlreadyReviewed90DoesNothing() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        decision.status = .reviewed90

        sut.handleVerdictTap(for: decision)

        XCTAssertFalse(sut.showVerdict)
    }
}
