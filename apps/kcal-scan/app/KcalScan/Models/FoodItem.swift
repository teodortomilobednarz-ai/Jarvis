import Foundation

enum FoodSource: String, Codable {
    case openFoodFacts
    case vision
    case manual
}

/// Aliment de référence (valeurs pour 100 g). Indépendant de la portion consommée.
struct FoodItem: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var brand: String?
    var barcode: String?
    var per100g: MacroNutrients
    var kcalPer100g: Double
    var source: FoodSource

    init(id: UUID = UUID(),
         name: String,
         brand: String? = nil,
         barcode: String? = nil,
         per100g: MacroNutrients,
         kcalPer100g: Double,
         source: FoodSource) {
        self.id = id
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.per100g = per100g
        self.kcalPer100g = kcalPer100g
        self.source = source
    }
}
