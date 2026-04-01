import Foundation
import SwiftData

@Model
final class CheckIn {
    @Attribute(.unique) var id: UUID
    var date: Date
    var moodScore: Int
    var activitiesRaw: [String]
    var emotionsRaw: [String]
    var title: String?
    var note: String?
    @Attribute(.externalStorage) var photoData: Data?
    var isVoiceEntry: Bool
    var reformulation: String?

    var activities: [Activity] {
        get { activitiesRaw.compactMap { Activity(rawValue: $0) } }
        set { activitiesRaw = newValue.map(\.rawValue) }
    }

    var emotions: [Emotion] {
        get { emotionsRaw.compactMap { Emotion(rawValue: $0) } }
        set { emotionsRaw = newValue.map(\.rawValue) }
    }

    init(
        date: Date = Date(),
        moodScore: Int,
        activities: [Activity] = [],
        emotions: [Emotion] = [],
        title: String? = nil,
        note: String? = nil,
        photoData: Data? = nil,
        isVoiceEntry: Bool = false
    ) {
        self.id = UUID()
        self.date = date
        self.moodScore = moodScore
        self.activitiesRaw = activities.map(\.rawValue)
        self.emotionsRaw = emotions.map(\.rawValue)
        self.title = title
        self.note = note
        self.photoData = photoData
        self.isVoiceEntry = isVoiceEntry
        self.reformulation = nil
    }
}
