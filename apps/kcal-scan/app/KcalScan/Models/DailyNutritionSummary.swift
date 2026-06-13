import Foundation

/// Synthèse calculée d'une journée. Non persistée (dérivée des entrées + HealthKit + objectif).
struct DailyNutritionSummary {
    var date: Date
    var entries: [FoodEntry]
    var steps: Int
    var activeEnergyKcal: Double
    var goal: NutritionGoal

    var consumedKcal: Double { entries.reduce(0) { $0 + $1.kcal } }

    var consumedMacros: MacroNutrients {
        entries.reduce(.zero) { $0 + $1.macros }
    }

    /// Calories restantes = cible − consommé. (La dépense active influe via le TDEE/goal.)
    var remainingKcal: Double { goal.targetKcal - consumedKcal }

    func entries(for meal: MealType) -> [FoodEntry] {
        entries.filter { $0.mealType == meal }
    }

    static func empty(date: Date = Date(), goal: NutritionGoal = .empty) -> DailyNutritionSummary {
        DailyNutritionSummary(date: date, entries: [], steps: 0, activeEnergyKcal: 0, goal: goal)
    }
}
