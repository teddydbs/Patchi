import SwiftUI

extension Font {
    /// Titre émotionnel — Crimson Pro Italic (fallback: serif italic système)
    static func patchiTitle(_ size: CGFloat = 28) -> Font {
        if UIFont(name: "CrimsonPro-Italic", size: size) != nil {
            return .custom("CrimsonPro-Italic", size: size, relativeTo: .title)
        }
        return .system(size: size, weight: .regular, design: .serif).italic()
    }

    /// Corps émotionnel — Crimson Pro Regular
    static func patchiBody(_ size: CGFloat = 18) -> Font {
        if UIFont(name: "CrimsonPro-Regular", size: size) != nil {
            return .custom("CrimsonPro-Regular", size: size, relativeTo: .body)
        }
        return .system(size: size, weight: .regular, design: .serif)
    }

    /// Citation — Crimson Pro Italic plus grand
    static func patchiQuote(_ size: CGFloat = 24) -> Font {
        if UIFont(name: "CrimsonPro-Italic", size: size) != nil {
            return .custom("CrimsonPro-Italic", size: size, relativeTo: .title2)
        }
        return .system(size: size, weight: .regular, design: .serif).italic()
    }

    /// Reformulation Patchi
    static func patchiReformulation(_ size: CGFloat = 20) -> Font {
        if UIFont(name: "CrimsonPro-MediumItalic", size: size) != nil {
            return .custom("CrimsonPro-MediumItalic", size: size, relativeTo: .title3)
        }
        return .system(size: size, weight: .medium, design: .serif).italic()
    }

    /// Label interface — SF Pro (système)
    static func patchiLabel(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium)
    }
}

// MARK: - Instructions pour intégrer Crimson Pro
/*
 1. Télécharger depuis https://fonts.google.com/specimen/Crimson+Pro
 2. Copier dans Patchi/Resources/Fonts/ :
    - CrimsonPro-Regular.ttf
    - CrimsonPro-Italic.ttf
    - CrimsonPro-Medium.ttf
    - CrimsonPro-MediumItalic.ttf
    - CrimsonPro-SemiBold.ttf
    - CrimsonPro-SemiBoldItalic.ttf
 3. Ajouter dans Info.plist :
    <key>UIAppFonts</key>
    <array>
        <string>Fonts/CrimsonPro-Regular.ttf</string>
        <string>Fonts/CrimsonPro-Italic.ttf</string>
        <string>Fonts/CrimsonPro-Medium.ttf</string>
        <string>Fonts/CrimsonPro-MediumItalic.ttf</string>
        <string>Fonts/CrimsonPro-SemiBold.ttf</string>
        <string>Fonts/CrimsonPro-SemiBoldItalic.ttf</string>
    </array>
 4. Les Font.patchiTitle() etc. détecteront automatiquement la police.
    En attendant, le fallback serif système est utilisé.
 */
