import Foundation

/// Mapping score d'humeur → nom d'asset illustration.
///
/// Les illustrations d'émotions (`emotion_heureux`, `emotion_serein`, etc.)
/// sont stockées dans `Resources/Assets.xcassets/`. Ce helper centralise
/// le mapping pour éviter les duplications dans HomeView, EntryCardView,
/// StatsView, etc.
enum MoodImage {
    /// Retourne le nom de l'asset correspondant au score d'humeur 1-5.
    /// Fallback : `emotion_serein` pour les scores hors plage.
    static func name(forScore score: Int) -> String {
        switch score {
        case 5: "emotion_heureux"
        case 4: "emotion_serein"
        case 3: "emotion_nostalgique"
        case 2: "emotion_triste"
        case 1: "emotion_seul"
        default: "emotion_serein"
        }
    }
}
