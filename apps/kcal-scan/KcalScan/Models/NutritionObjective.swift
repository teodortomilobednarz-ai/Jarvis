import Foundation

/// Objectif nutritionnel. Détermine l'ajustement calorique et la cible macros.
enum NutritionObjective: String, Codable, CaseIterable, Identifiable {
    case cut          // sèche
    case weightLoss   // perte de poids
    case maintenance  // maintien
    case bulk         // prise de masse

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cut:         return "Sèche"
        case .weightLoss:  return "Perte de poids"
        case .maintenance: return "Maintien"
        case .bulk:        return "Prise de masse"
        }
    }

    /// Multiplicateur appliqué au TDEE pour obtenir la cible calorique.
    var calorieMultiplier: Double {
        switch self {
        case .cut:         return 0.78   // ~ -22 %
        case .weightLoss:  return 0.82   // ~ -18 %
        case .maintenance: return 1.0
        case .bulk:        return 1.12    // ~ +12 %
        }
    }

    /// Protéines visées en g/kg de poids corporel.
    var proteinPerKg: Double {
        switch self {
        case .cut:         return 2.2
        case .weightLoss:  return 2.0
        case .maintenance: return 1.8
        case .bulk:        return 1.8
        }
    }

    /// Lipides visés en g/kg de poids corporel.
    var fatPerKg: Double {
        switch self {
        case .cut:         return 0.8
        case .weightLoss:  return 0.9
        case .maintenance: return 1.0
        case .bulk:        return 1.0
        }
    }
}
