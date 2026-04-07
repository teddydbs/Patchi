import XCTest
@testable import Patchi

final class VerdictViewModelTests: XCTestCase {
    private var sut: VerdictViewModel!

    override func setUp() {
        super.setUp()
        sut = VerdictViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Save Verdict J+30

    func testSaveVerdictJ30UpdatesDecision() {
        let decision = Decision(title: "Test", context: "", prediction: "Ça va marcher", decision: "Go")
        sut.selectedVerdict = .right
        sut.whatHappened = "Ça a marché !"

        sut.saveVerdict(decision: decision, verdictType: .j30)

        XCTAssertEqual(decision.verdict30, .right)
        XCTAssertEqual(decision.whatHappened30, "Ça a marché !")
        XCTAssertEqual(decision.status, .reviewed30)
        XCTAssertTrue(sut.isSaved)
    }

    // MARK: - Save Verdict J+90

    func testSaveVerdictJ90UpdatesDecision() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        decision.status = .reviewed30
        sut.selectedVerdict = .wrong
        sut.whatHappened = "Finalement non"

        sut.saveVerdict(decision: decision, verdictType: .j90)

        XCTAssertEqual(decision.verdict90, .wrong)
        XCTAssertEqual(decision.whatHappened90, "Finalement non")
        XCTAssertEqual(decision.status, .reviewed90)
    }

    // MARK: - Save Without Verdict

    func testSaveWithoutVerdictDoesNothing() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        sut.selectedVerdict = nil

        sut.saveVerdict(decision: decision, verdictType: .j30)

        XCTAssertNil(decision.verdict30)
        XCTAssertEqual(decision.status, .pending)
        XCTAssertFalse(sut.isSaved)
    }

    // MARK: - Empty WhatHappened

    func testSaveWithEmptyWhatHappenedSetsNil() {
        let decision = Decision(title: "Test", context: "", prediction: "", decision: "")
        sut.selectedVerdict = .partial
        sut.whatHappened = "   "

        sut.saveVerdict(decision: decision, verdictType: .j30)

        XCTAssertNil(decision.whatHappened30, "Whitespace-only doit donner nil")
    }

    // MARK: - Completion Expression

    func testCompletionExpressionRight() {
        sut.selectedVerdict = .right
        XCTAssertEqual(sut.completionExpression, .celebrating)
    }

    func testCompletionExpressionPartial() {
        sut.selectedVerdict = .partial
        XCTAssertEqual(sut.completionExpression, .thinking)
    }

    func testCompletionExpressionWrong() {
        sut.selectedVerdict = .wrong
        XCTAssertEqual(sut.completionExpression, .comforting)
    }

    func testCompletionExpressionNil() {
        sut.selectedVerdict = nil
        XCTAssertEqual(sut.completionExpression, .neutral)
    }

    // MARK: - Completion Phrase

    func testCompletionPhraseChangesWithVerdict() {
        sut.selectedVerdict = .right
        let phraseRight = sut.completionPhrase

        sut.selectedVerdict = .wrong
        let phraseWrong = sut.completionPhrase

        XCTAssertNotEqual(phraseRight, phraseWrong)
    }
}
