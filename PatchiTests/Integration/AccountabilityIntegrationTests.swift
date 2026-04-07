import XCTest
import SwiftData
@testable import Patchi

/// Tests d'intégration : AccountabilityViewModel + SwiftData + HeatmapService
final class AccountabilityIntegrationTests: XCTestCase {
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

    // MARK: - Accountability save → SwiftData → Heatmap

    func testAccountabilitySaveAndHeatmap() throws {
        let vm = AccountabilityViewModel()
        vm.missedAction = "Je n'ai pas fait de sport"
        vm.reason = "Trop fatigué"
        vm.isReasonValid = true
        vm.importance = 4

        vm.save(context: context)

        // Vérifier SwiftData
        let descriptor = FetchDescriptor<AccountabilityEntry>()
        let entries = try context.fetch(descriptor)

        XCTAssertEqual(entries.count, 1)
        let saved = entries.first!
        XCTAssertEqual(saved.missedAction, "Je n'ai pas fait de sport")
        XCTAssertEqual(saved.reason, "Trop fatigué")
        XCTAssertEqual(saved.importance, 4)
        XCTAssertEqual(saved.heatmapColor, .orange)
        XCTAssertFalse(saved.isSkipped)

        // Vérifier que le HeatmapService lit correctement l'entrée
        let heatmap = HeatmapService.generateHeatmap(from: entries)
        let todayEntry = heatmap.last!
        XCTAssertFalse(todayEntry.isEmpty)
        XCTAssertEqual(todayEntry.color, .orange)
        XCTAssertEqual(todayEntry.importance, 4)
    }

    // MARK: - Skip positif → heatmap vert

    func testSkipSaveAndHeatmap() throws {
        let vm = AccountabilityViewModel()
        vm.saveSkip(context: context)

        let descriptor = FetchDescriptor<AccountabilityEntry>()
        let entries = try context.fetch(descriptor)

        XCTAssertEqual(entries.count, 1)
        let saved = entries.first!
        XCTAssertTrue(saved.isSkipped)
        XCTAssertEqual(saved.heatmapColor, .darkGreen)

        // Heatmap doit montrer du vert
        let heatmap = HeatmapService.generateHeatmap(from: entries)
        let todayEntry = heatmap.last!
        XCTAssertEqual(todayEntry.color, .darkGreen)
    }

    // MARK: - Raison non valable → heatmap rouge

    func testInvalidReasonSaveAndHeatmap() throws {
        let vm = AccountabilityViewModel()
        vm.missedAction = "Pas allé courir"
        vm.isReasonValid = false
        vm.importance = 5

        vm.save(context: context)

        let descriptor = FetchDescriptor<AccountabilityEntry>()
        let entries = try context.fetch(descriptor)

        XCTAssertEqual(entries.first?.heatmapColor, .red)

        let heatmap = HeatmapService.generateHeatmap(from: entries)
        let todayEntry = heatmap.last!
        XCTAssertEqual(todayEntry.color, .red)
    }

    // MARK: - Heatmap stats avec plusieurs jours

    func testHeatmapStatsMultipleDays() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Simuler 5 jours d'entrées
        for i in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let entry = AccountabilityEntry(
                date: date,
                missedAction: "Test \(i)",
                importance: 3,
                heatmapColor: i == 0 ? .red : .darkGreen
            )
            context.insert(entry)
        }

        let descriptor = FetchDescriptor<AccountabilityEntry>()
        let entries = try context.fetch(descriptor)
        let heatmap = HeatmapService.generateHeatmap(from: entries)
        let stats = HeatmapService.computeStats(from: heatmap)

        XCTAssertEqual(stats.filledDays, 5)
        XCTAssertEqual(stats.redDays, 1)
        XCTAssertEqual(stats.greenDays, 4)
        XCTAssertGreaterThan(stats.currentStreak, 0)
    }

    // MARK: - Yesterday catch-up

    func testYesterdayCatchUp() throws {
        let vm = AccountabilityViewModel()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!

        // Simuler la détection de hier manqué
        vm.checkYesterday(entries: [])
        XCTAssertTrue(vm.hasMissedYesterday)

        // Rattraper
        vm.missedAction = "Pas de méditation"
        vm.yesterdayDate = yesterday
        vm.saveYesterdayCatchUp(context: context)

        let descriptor = FetchDescriptor<AccountabilityEntry>()
        let entries = try context.fetch(descriptor)

        XCTAssertEqual(entries.count, 1)
        XCTAssertTrue(Calendar.current.isDate(entries.first!.date, inSameDayAs: yesterday))
        XCTAssertFalse(vm.hasMissedYesterday)
    }
}
