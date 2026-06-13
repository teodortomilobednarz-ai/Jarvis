import Foundation

/// Objectif calculé : cible calorique + macros, dérivé du profil et du TDEE.
struct NutritionGoal: Codable, Hashable {
    var targetKcal: Double
    var macros: MacroNutrients
    var objective: NutritionObjective
    var tdee: Double
    var bmr: Double

    static let empty = NutritionGoal(targetKcal: 0,
                                     macros: .zero,
                                     objective: .maintenance,
                                     tdee: 0,
                                     bmr: 0)
}
