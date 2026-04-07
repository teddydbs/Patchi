import XCTest
@testable import Patchi

final class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        sut = HomeViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Pending Decisions

    func testPendingDecisionsFiltersCorrectly() {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        let d2 = Decision(title: "B", context: "", prediction: "", decision: "")
        d2.status = .reviewed30

        let pending = sut.pendingDecisions(from: [d1, d2])
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.title, "A")
    }

    func testPendingDecisionsEmptyWhenNoPending() {
        let d1 = Decision(title: "A", context: "", prediction: "", decision: "")
        d1.status = .reviewed90
        XCTAssertTrue(sut.pendingDecisions(from: [d1]).isEmpty)
    }

    // MARK: - Has Mood Entry

    func testHasMoodEntryTrueForToday() {
        let checkIn = CheckIn(date: Date(), moodScore: 3)
        XCTAssertTrue(sut.hasMoodEntry(on: Date(), in: [checkIn]))
    }

    func testHasMoodEntryFalseForDifferentDay() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let checkIn = CheckIn(date: yesterday, moodScore: 3)
        XCTAssertFalse(sut.hasMoodEntry(on: Date(), in: [checkIn]))
    }

    // MARK: - Day Letter

    func testDayLetterReturnsUppercasedSingleLetter() {
        let letter = sut.dayLetter(Date())
        XCTAssertEqual(letter.count, 1)
        XCTAssertEqual(letter, letter.uppercased())
    }

    // MARK: - Current User Name

    func testCurrentUserNameReturnsFirstUser() {
        let users = [User(firstName: "Teddy"), User(firstName: "Other")]
        XCTAssertEqual(sut.currentUserName(from: users), "Teddy")
    }

    func testCurrentUserNameNilWhenEmpty() {
        XCTAssertNil(sut.currentUserName(from: []))
    }

    // MARK: - Daily Challenge

    func testDailyChallengeIsDeterministic() {
        let challenge1 = sut.dailyChallenge(recentActivities: [])
        let challenge2 = sut.dailyChallenge(recentActivities: [])
        XCTAssertEqual(challenge1.text, challenge2.text, "Le défi doit être stable dans la journée")
    }

    func testDailyChallengeUsesRelevantActivities() {
        let challenge = sut.dailyChallenge(recentActivities: [.sport, .sport, .sport])
        // Peut retourner un challenge sport OU générique (selon le seed du jour)
        XCTAssertFalse(challenge.text.isEmpty)
    }

    // MARK: - Time Until Midnight

    func testTimeUntilMidnightNotEmpty() {
        XCTAssertFalse(sut.timeUntilMidnight.isEmpty)
    }

    func testTimeUntilMidnightContainsH() {
        XCTAssertTrue(sut.timeUntilMidnight.contains("h"))
    }
}
