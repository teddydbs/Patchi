import Foundation
import SwiftData

@Model
final class Decision {
    @Attribute(.unique) var id: UUID
    var title: String
    var context: String
    var prediction: String
    var decision: String
    var importance: Int
    var createdAt: Date
    var reviewAt30: Date
    var reviewAt90: Date
    var verdict30Raw: String?
    var verdict90Raw: String?
    var whatHappened30: String?
    var whatHappened90: String?
    var confidence: Int?
    var statusRaw: String

    var verdict30: Verdict? {
        get { verdict30Raw.flatMap { Verdict(rawValue: $0) } }
        set { verdict30Raw = newValue?.rawValue }
    }

    var verdict90: Verdict? {
        get { verdict90Raw.flatMap { Verdict(rawValue: $0) } }
        set { verdict90Raw = newValue?.rawValue }
    }

    var status: DecisionStatus {
        get { DecisionStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        title: String,
        context: String,
        prediction: String,
        decision: String,
        importance: Int = 3,
        confidence: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.context = context
        self.prediction = prediction
        self.decision = decision
        self.importance = min(max(importance, 1), 5)
        self.createdAt = Date()
        self.reviewAt30 = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        self.reviewAt90 = Calendar.current.date(byAdding: .day, value: 90, to: Date())!
        self.verdict30Raw = nil
        self.verdict90Raw = nil
        self.whatHappened30 = nil
        self.whatHappened90 = nil
        self.confidence = confidence
        self.statusRaw = DecisionStatus.pending.rawValue
    }
}
