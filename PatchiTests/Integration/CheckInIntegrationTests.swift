import XCTest
import SwiftData
@testable import Patchi

/// Tests d'intégration : CheckInViewModel + SwiftData + ReformulationService
final class CheckInIntegrationTests: XCTestCase {
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

    // MARK: - Check-in complet : ViewModel → save → SwiftData → reformulation

    func testCheckInFullFlow() throws {
        let vm = CheckInViewModel()
        vm.moodScore = 4
        vm.selectedActivities = [.sport, .nature]
        vm.selectedEmotions = [.heureux, .serein]
        vm.title = "Belle journée"
        vm.note = "J'ai couru dans la forêt"

        vm.save(context: context)

        // Vérifier que l'entrée est dans SwiftData
        let descriptor = FetchDescriptor<CheckIn>()
        let checkIns = try context.fetch(descriptor)

        XCTAssertEqual(checkIns.count, 1)

        let saved = checkIns.first!
        XCTAssertEqual(saved.moodScore, 4)
        XCTAssertEqual(saved.title, "Belle journée")
        XCTAssertEqual(saved.note, "J'ai couru dans la forêt")
        XCTAssertEqual(saved.activities, [.sport, .nature])
        XCTAssertEqual(saved.emotions, [.heureux, .serein])
        XCTAssertFalse(saved.isVoiceEntry)
        XCTAssertTrue(vm.isCompleted)
    }

    // MARK: - Reformulation via ReformulationService

    func testReformulationGeneratesText() {
        let vm = CheckInViewModel()
        vm.moodScore = 3
        vm.note = "Je suis fatigué du travail"

        vm.save(context: context)

        // La reformulation est générée avant le save dans le flow normal,
        // mais le service doit fonctionner indépendamment
        let reformulation = ReformulationService.shared.reformulate("Je suis fatigué du travail")
        XCTAssertFalse(reformulation.isEmpty)
    }

    // MARK: - Multiples check-ins dans la même journée

    func testMultipleCheckInsSameDay() throws {
        let vm1 = CheckInViewModel()
        vm1.moodScore = 2
        vm1.save(context: context)

        let vm2 = CheckInViewModel()
        vm2.moodScore = 5
        vm2.save(context: context)

        let descriptor = FetchDescriptor<CheckIn>()
        let checkIns = try context.fetch(descriptor)

        XCTAssertEqual(checkIns.count, 2)
    }

    // MARK: - Stats après check-ins

    func testStatsViewModelReadsCheckInsFromContext() throws {
        // Insérer des check-ins directement
        let today = Calendar.current.startOfDay(for: Date())
        context.insert(CheckIn(date: today, moodScore: 5, activities: [.sport]))
        context.insert(CheckIn(date: today, moodScore: 3, activities: [.sport]))
        context.insert(CheckIn(date: today, moodScore: 4, activities: [.lecture]))

        let descriptor = FetchDescriptor<CheckIn>()
        let checkIns = try context.fetch(descriptor)

        let statsVM = StatsViewModel()
        let weekly = statsVM.weeklyMoods(from: checkIns)

        // Aujourd'hui devrait avoir une moyenne de 4.0
        let todayMood = weekly.last!
        XCTAssertEqual(todayMood.averageScore, 4.0, accuracy: 0.01)

        // Corrélations : sport a 2 entrées, lecture 1
        let correlations = statsVM.correlations(from: checkIns)
        XCTAssertTrue(correlations.contains { $0.activity == .sport })
    }
}
