import Foundation

enum Activity: String, Codable, CaseIterable, Identifiable {
    case travail
    case famille
    case amis
    case sport
    case sante
    case projetPerso
    case repos
    case voyage
    case musique
    case lecture
    case cuisine
    case nature
    case meditation
    case shopping
    case jeux
    case hobbies
    case ecole
    case relationAmoureuse
    case sorties
    case benevolat

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .travail: "Travail"
        case .famille: "Famille"
        case .amis: "Amis"
        case .sport: "Sport"
        case .sante: "Santé"
        case .projetPerso: "Projet perso"
        case .repos: "Repos"
        case .voyage: "Voyage"
        case .musique: "Musique"
        case .lecture: "Lecture"
        case .cuisine: "Cuisine"
        case .nature: "Nature"
        case .meditation: "Méditation"
        case .shopping: "Shopping"
        case .jeux: "Jeux"
        case .hobbies: "Hobbies"
        case .ecole: "École"
        case .relationAmoureuse: "Relation"
        case .sorties: "Sorties"
        case .benevolat: "Bénévolat"
        }
    }

    var icon: String {
        switch self {
        case .travail: "briefcase.fill"
        case .famille: "house.fill"
        case .amis: "person.2.fill"
        case .sport: "figure.run"
        case .sante: "heart.fill"
        case .projetPerso: "lightbulb.fill"
        case .repos: "bed.double.fill"
        case .voyage: "airplane"
        case .musique: "music.note"
        case .lecture: "book.fill"
        case .cuisine: "fork.knife"
        case .nature: "leaf.fill"
        case .meditation: "brain.head.profile.fill"
        case .shopping: "bag.fill"
        case .jeux: "gamecontroller.fill"
        case .hobbies: "paintbrush.fill"
        case .ecole: "graduationcap.fill"
        case .relationAmoureuse: "heart.circle.fill"
        case .sorties: "party.popper.fill"
        case .benevolat: "hands.sparkles.fill"
        }
    }
}
