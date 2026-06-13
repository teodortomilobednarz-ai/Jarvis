import Foundation

enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
    case male, female, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .male:   return "Homme"
        case .female: return "Femme"
        case .other:  return "Autre"
        }
    }
}

/// Profil corporel de l'utilisateur. Source de vérité pour les calculs nutritionnels.
struct UserProfile: Codable, Identifiable, Hashable {
    var id: UUID
    var sex: BiologicalSex
    var birthDate: Date
    var heightCm: Double
    var weightKg: Double
    var activityLevel: ActivityLevel
    var objective: NutritionObjective
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(),
         sex: BiologicalSex,
         birthDate: Date,
         heightCm: Double,
         weightKg: Double,
         activityLevel: ActivityLevel,
         objective: NutritionObjective,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.sex = sex
        self.birthDate = birthDate
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevel = activityLevel
        self.objective = objective
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
}
