import Foundation

/// Répartition des macronutriments en grammes. `kcal` est dérivé (4/4/9).
struct MacroNutrients: Codable, Hashable {
    var protein: Double
    var carbs: Double
    var fat: Double

    static let zero = MacroNutrients(protein: 0, carbs: 0, fat: 0)

    /// Calories issues des macros (4 kcal/g protéines et glucides, 9 kcal/g lipides).
    var kcal: Double { protein * 4 + carbs * 4 + fat * 9 }

    func scaled(by factor: Double) -> MacroNutrients {
        MacroNutrients(protein: protein * factor, carbs: carbs * factor, fat: fat * factor)
    }

    static func + (lhs: MacroNutrients, rhs: MacroNutrients) -> MacroNutrients {
        MacroNutrients(protein: lhs.protein + rhs.protein,
                       carbs: lhs.carbs + rhs.carbs,
                       fat: lhs.fat + rhs.fat)
    }
}
