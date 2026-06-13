import Foundation

/// Niveau d'activité utilisé comme facteur PAL en mode repli (sans HealthKit).
enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary
    case light
    case moderate
    case intense
    case athlete

    var id: String { rawValue }

    /// Facteur d'activité physique (Physical Activity Level).
    var palFactor: Double {
        switch self {
        case .sedentary: return 1.2
        case .light:     return 1.375
        case .moderate:  return 1.55
        case .intense:   return 1.725
        case .athlete:   return 1.9
        }
    }

    var label: String {
        switch self {
        case .sedentary: return "Sédentaire"
        case .light:     return "Léger (1-3 j/sem)"
        case .moderate:  return "Modéré (3-5 j/sem)"
        case .intense:   return "Intense (6-7 j/sem)"
        case .athlete:   return "Très intense / athlète"
        }
    }
}
