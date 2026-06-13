import Foundation

/// Aliment effectivement consommé : un `FoodItem` + une portion + un repas.
struct FoodEntry: Codable, Identifiable, Hashable {
    var id: UUID
    var date: Date
    var mealType: MealType
    var foodItem: FoodItem
    var portionGrams: Double
    var source: FoodSource

    init(id: UUID = UUID(),
         date: Date = Date(),
         mealType: MealType,
         foodItem: FoodItem,
         portionGrams: Double,
         source: FoodSource) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.foodItem = foodItem
        self.portionGrams = portionGrams
        self.source = source
    }

    private var factor: Double { portionGrams / 100.0 }

    var macros: MacroNutrients { foodItem.per100g.scaled(by: factor) }
    var kcal: Double { foodItem.kcalPer100g * factor }
}
