import XCTest
import SwiftData
@testable import Kokora

/// Tests d'intégration : Decision flow complet — créer → verdict J+30 → verdict J+90
final class DecisionIntegrationTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(
            for: CheckIn.self, User.self, Decision.self, AccountabilityEntry.self, FutureLetter.self,
            configurations: config
        )
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - Flow complet : créer → J+30 → J+90

    func testDecisionFullLifecycle() throws {
        // 1. Créer une décision
        let decision = Decision(
            title: "Changer de travail",
            context: "Je ne suis plus heureux",
            prediction: "Je serai mieux",
            decision: "J'ai démissionné",
            importance: 5
        )
        context.insert(decision)

        let descriptor = FetchDescriptor<Decision>()
        var decisions = try context.fetch(descriptor)
        XCTAssertEqual(decisions.count, 1)
        XCTAssertEqual(decisions.first?.status, .pending)

        // 2. Simuler J+30 — verdict positif
        let verdictVM = VerdictViewModel()
        verdictVM.selectedVerdict = .right
        verdictVM.whatHappened = "Meilleur environnement, je suis content"
        verdictVM.saveVerdict(decision: decision, verdictType: .j30)

        decisions = try context.fetch(descriptor)
        let updated = decisions.first!
        XCTAssertEqual(updated.status, .reviewed30)
        XCTAssertEqual(updated.verdict30, .right)
        XCTAssertEqual(updated.whatHappened30, "Meilleur environnement, je suis content")

        // 3. Simuler J+90 — verdict partiel
        let verdictVM90 = VerdictViewModel()
        verdictVM90.selectedVerdict = .partial
        verdictVM90.whatHappened = "Quelques doutes mais globalement mieux"
        verdictVM90.saveVerdict(decision: decision, verdictType: .j90)

        decisions = try context.fetch(descriptor)
        let final_ = decisions.first!
        XCTAssertEqual(final_.status, .reviewed90)
        XCTAssertEqual(final_.verdict90, .partial)
        XCTAssertEqual(final_.whatHappened90, "Quelques doutes mais globalement mieux")
    }

    // MARK: - DecisionListViewModel filtre les données SwiftData

    func testDecisionListViewModelWithSwiftData() throws {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        let d2 = Decision(title: "B", context: "", prediction: "", decision: "")
        let d3 = Decision(title: "C", context: "", prediction: "", decision: "")
        context.insert(d1)
        context.insert(d2)
        context.insert(d3)

        // Passer B en reviewed30
        d2.status = .reviewed30
        d2.verdict30 = .right

        let descriptor = FetchDescriptor<Decision>()
        let decisions = try context.fetch(descriptor)

        let listVM = DecisionListViewModel()

        // Sans filtre
        XCTAssertEqual(listVM.filteredDecisions(from: decisions).count, 3)

        // Filtre pending
        listVM.selectedFilter = .pending
        XCTAssertEqual(listVM.filteredDecisions(from: decisions).count, 2)

        // Filtre reviewed30
        listVM.selectedFilter = .reviewed30
        let reviewed = listVM.filteredDecisions(from: decisions)
        XCTAssertEqual(reviewed.count, 1)
        XCTAssertEqual(reviewed.first?.title, "B")
    }

    // MARK: - Verdict dû détecté correctement

    func testVerdictDueDetection() throws {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        // Forcer reviewAt30 dans le passé
        decision.reviewAt30 = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        context.insert(decision)

        let listVM = DecisionListViewModel()
        listVM.handleVerdictTap(for: decision)

        XCTAssertTrue(listVM.showVerdict)
        XCTAssertEqual(listVM.verdictType, .j30)
    }

    // MARK: - Stats décisions depuis SwiftData

    func testStatsViewModelReadsDecisionsFromContext() throws {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        let d2 = Decision(title: "B", context: "", prediction: "", decision: "")
        d2.status = .reviewed30
        let d3 = Decision(title: "C", context: "", prediction: "", decision: "")
        d3.status = .reviewed90

        context.insert(d1)
        context.insert(d2)
        context.insert(d3)

        let descriptor = FetchDescriptor<Decision>()
        let decisions = try context.fetch(descriptor)

        let statsVM = StatsViewModel()
        let counts = statsVM.decisionCounts(from: decisions)

        XCTAssertEqual(counts.total, 3)
        XCTAssertEqual(counts.pending, 1)
        XCTAssertEqual(counts.reviewed, 2)
    }
}
