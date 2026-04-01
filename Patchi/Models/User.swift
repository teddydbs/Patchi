import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var email: String?
    var appleUserIdentifier: String?
    var createdAt: Date
    var isPremium: Bool
    var premiumExpiresAt: Date?
    var onboardingCompleted: Bool
    var notificationStartHour: Int
    var notificationEndHour: Int
    var notificationCount: Int
    var selectedTheme: String
    var biometricLockEnabled: Bool

    init(
        firstName: String,
        email: String? = nil,
        appleUserIdentifier: String? = nil
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.email = email
        self.appleUserIdentifier = appleUserIdentifier
        self.createdAt = Date()
        self.isPremium = false
        self.premiumExpiresAt = nil
        self.onboardingCompleted = false
        self.notificationStartHour = 19
        self.notificationEndHour = 22
        self.notificationCount = 1
        self.selectedTheme = AppTheme.default.rawValue
        self.biometricLockEnabled = false
    }
}
