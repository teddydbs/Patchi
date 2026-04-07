import SwiftUI

extension Font {
    /// Titre émotionnel — Crimson Pro Italic
    static func patchiTitle(_ size: CGFloat = 28) -> Font {
        .custom("CrimsonPro-Italic", size: size, relativeTo: .title)
    }

    /// Corps émotionnel — Crimson Pro Regular
    static func patchiBody(_ size: CGFloat = 18) -> Font {
        .custom("CrimsonPro-Regular", size: size, relativeTo: .body)
    }

    /// Citation — Crimson Pro Italic plus grand
    static func patchiQuote(_ size: CGFloat = 24) -> Font {
        .custom("CrimsonPro-Italic", size: size, relativeTo: .title2)
    }

    /// Reformulation Patchi
    static func patchiReformulation(_ size: CGFloat = 20) -> Font {
        .custom("CrimsonPro-MediumItalic", size: size, relativeTo: .title3)
    }

    /// Label interface — SF Pro (système)
    static func patchiLabel(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium)
    }
}
