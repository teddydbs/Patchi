import SwiftUI

extension Font {
    /// Titre émotionnel — Crimson Pro Italic
    static func kokoraTitle(_ size: CGFloat = 28) -> Font {
        .custom("CrimsonPro-Italic", size: size, relativeTo: .title)
    }

    /// Corps émotionnel — Crimson Pro Regular
    static func kokoraBody(_ size: CGFloat = 18) -> Font {
        .custom("CrimsonPro-Regular", size: size, relativeTo: .body)
    }

    /// Citation — Crimson Pro Italic plus grand
    static func kokoraQuote(_ size: CGFloat = 24) -> Font {
        .custom("CrimsonPro-Italic", size: size, relativeTo: .title2)
    }

    /// Reformulation Kokora
    static func kokoraReformulation(_ size: CGFloat = 20) -> Font {
        .custom("CrimsonPro-MediumItalic", size: size, relativeTo: .title3)
    }

    /// Label interface — SF Pro (système)
    static func kokoraLabel(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium)
    }

    // MARK: - ClashDisplay (onboarding / UI display)

    /// Graisses disponibles pour ClashDisplay (cf. Resources/Fonts/).
    enum ClashDisplayWeight {
        case regular, medium, semibold, bold

        fileprivate var fontName: String {
            switch self {
            case .regular: "ClashDisplay-Regular"
            case .medium: "ClashDisplay-Medium"
            case .semibold: "ClashDisplay-Semibold"
            case .bold: "ClashDisplay-Bold"
            }
        }

        fileprivate var relativeTextStyle: Font.TextStyle {
            switch self {
            case .regular, .medium: .body
            case .semibold: .headline
            case .bold: .title
            }
        }
    }

    /// Typo display ClashDisplay — headings et labels onboarding.
    /// Utilise `relativeTo:` pour supporter Dynamic Type automatiquement.
    static func kokoraDisplay(_ size: CGFloat, weight: ClashDisplayWeight = .semibold) -> Font {
        .custom(weight.fontName, size: size, relativeTo: weight.relativeTextStyle)
    }
}
