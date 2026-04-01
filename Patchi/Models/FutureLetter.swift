import Foundation
import SwiftData

@Model
final class FutureLetter {
    @Attribute(.unique) var id: UUID
    var content: String
    var writtenAt: Date
    var deliverAt: Date
    var isDelivered: Bool
    var reply: String?
    var repliedAt: Date?

    init(content: String) {
        self.id = UUID()
        self.content = content
        self.writtenAt = Date()
        self.deliverAt = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
        self.isDelivered = false
        self.reply = nil
        self.repliedAt = nil
    }
}
