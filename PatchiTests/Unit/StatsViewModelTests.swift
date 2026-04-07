import XCTest
@testable import Patchi

final class StatsViewModelTests: XCTestCase {
    private var sut: StatsViewModel!

    override func setUp() {
        super.setUp()
        sut = StatsViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Weekly Moods

    func testWeeklyMoodsReturns7Days() {
        let checkIns = [
            CheckIn(date: Date(), moodScore: 4),
            CheckIn(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, moodScore: 3),
        ]
        let moods = sut.weeklyMoods(from: checkIns)
        XCTAssertEqual(moods.count, 7)
    }

    func testWeeklyMoodsEmptyCheckIns() {
        let moods = sut.weeklyMoods(from: [])
        XCTAssertEqual(moods.count, 7)
        XCTAssertTrue(moods.allSatisfy { $0.averageScore == 0 })
    }

    func testWeeklyMoodsCorrectAverage() {
        let today = Calendar.current.startOfDay(for: Date())
        let checkIns = [
            CheckIn(date: today, moodScore: 2),
            CheckIn(date: today, moodScore: 4),
        ]
        let moods = sut.weeklyMoods(from: checkIns)
        let todayMood = moods.last!
        XCTAssertEqual(todayMood.averageScore, 3.0, accuracy: 0.01)
    }

    // MARK: - Monthly Moods

    func testMonthlyMoodsReturns30Days() {
        let moods = sut.monthlyMoods(from: [])
        XCTAssertEqual(moods.count, 30)
    }

    // MARK: - Correlations

    func testCorrelationsEmptyCheckIns() {
        let correlations = sut.correlations(from: [])
        XCTAssertTrue(correlations.isEmpty)
    }

    func testCorrelationsNeedAtLeast2Occurrences() {
        let checkIns = [
            CheckIn(date: Date(), moodScore: 5, activities: [.sport]),
        ]
        let correlations = sut.correlations(from: checkIns)
        XCTAssertTrue(correlations.isEmpty, "Doit ignorer les activités avec < 2 occurrences")
    }

    func testCorrelationsCorrectAverage() {
        let checkIns = [
            CheckIn(date: Date(), moodScore: 5, activities: [.sport]),
            CheckIn(date: Date(), moodScore: 3, activities: [.sport]),
        ]
        let correlations = sut.correlations(from: checkIns)
        XCTAssertEqual(correlations.count, 1)
        XCTAssertEqual(correlations.first?.activity, .sport)
        XCTAssertEqual(correlations.first!.averageMood, 4.0, accuracy: 0.01)
    }

    func testCorrelationsSortedByMoodDescending() {
        let checkIns = [
            CheckIn(date: Date(), moodScore: 5, activities: [.sport]),
            CheckIn(date: Date(), moodScore: 5, activities: [.sport]),
            CheckIn(date: Date(), moodScore: 2, activities: [.travail]),
            CheckIn(date: Date(), moodScore: 2, activities: [.travail]),
        ]
        let correlations = sut.correlations(from: checkIns)
        XCTAssertEqual(correlations.first?.activity, .sport)
        XCTAssertEqual(correlations.last?.activity, .travail)
    }

    // MARK: - Insight Phrase

    func testInsightPhraseNilWhenNoData() {
        XCTAssertNil(sut.insightPhrase(from: []))
    }

    func testInsightPhraseNilWhenLowMood() {
        let checkIns = [
            CheckIn(date: Date(), moodScore: 1, activities: [.sport]),
            CheckIn(date: Date(), moodScore: 1, activities: [.sport]),
        ]
        XCTAssertNil(sut.insightPhrase(from: checkIns), "Pas d'insight si la moyenne est < 3.5")
    }

    func testInsightPhraseExistsWhenHighMood() {
        let checkIns = [
            CheckIn(date: Date(), moodScore: 5, activities: [.sport]),
            CheckIn(date: Date(), moodScore: 4, activities: [.sport]),
        ]
        let phrase = sut.insightPhrase(from: checkIns)
        XCTAssertNotNil(phrase)
        XCTAssertTrue(phrase!.contains("sport"))
    }

    // MARK: - Countdown

    func testCountdownFirstMilestoneAt3() {
        let countdown = sut.countdown(totalCheckIns: 0)
        XCTAssertNotNil(countdown)
        XCTAssertEqual(countdown?.remaining, 3)
    }

    func testCountdownSecondMilestoneAt7() {
        let countdown = sut.countdown(totalCheckIns: 5)
        XCTAssertNotNil(countdown)
        XCTAssertEqual(countdown?.remaining, 2)
    }

    func testCountdownNilWhenPast30() {
        let countdown = sut.countdown(totalCheckIns: 50)
        XCTAssertNil(countdown)
    }

    // MARK: - Decision Counts

    func testDecisionCountsEmpty() {
        let counts = sut.decisionCounts(from: [])
        XCTAssertEqual(counts.total, 0)
        XCTAssertEqual(counts.pending, 0)
        XCTAssertEqual(counts.reviewed, 0)
    }

    func testDecisionCountsMixed() {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        let d2 = Decision(title: "B", context: "", prediction: "", decision: "")
        d2.status = .reviewed30
        let d3 = Decision(title: "C", context: "", prediction: "", decision: "")
        d3.status = .reviewed90

        let counts = sut.decisionCounts(from: [d1, d2, d3])
        XCTAssertEqual(counts.total, 3)
        XCTAssertEqual(counts.pending, 1)
        XCTAssertEqual(counts.reviewed, 2)
    }
}
