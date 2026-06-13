import Foundation

/// Moteur de calcul nutritionnel — pur, sans I/O, entièrement testable.
enum NutritionCalculator {

    /// BMR Mifflin-St Jeor (kcal/jour).
    static func bmr(sex: BiologicalSex, weightKg: Double, heightCm: Double, age: Int) -> Double {
        let base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age)
        switch sex {
        case .male:   return base + 5
        case .female: return base - 161
        case .other:  return base - 78   // moyenne H/F
        }
    }

    /// TDEE précis : métabolisme de repos + dépense active réelle (HealthKit).
    static func tdee(bmr: Double, activeEnergyKcal: Double) -> Double {
        bmr * 1.2 + activeEnergyKcal
    }

    /// TDEE de repli : BMR × facteur d'activité déclaré.
    static func tdee(bmr: Double, activityLevel: ActivityLevel) -> Double {
        bmr * activityLevel.palFactor
    }

    /// Cible calorique selon l'objectif, avec plancher de sécurité.
    static func targetKcal(tdee: Double, bmr: Double, sex: BiologicalSex, objective: NutritionObjective) -> Double {
        let raw = tdee * objective.calorieMultiplier
        let absoluteFloor: Double = (sex == .female) ? 1200 : 1500
        // Ne jamais descendre sous le BMR ni sous le plancher absolu.
        return max(raw, bmr, absoluteFloor)
    }

    /// Répartition macros : protéines et lipides en g/kg, glucides = reste des calories.
    static func macros(weightKg: Double, objective: NutritionObjective, targetKcal: Double) -> MacroNutrients {
        let protein = weightKg * objective.proteinPerKg
        let fat = weightKg * objective.fatPerKg
        let remainingKcal = max(0, targetKcal - (protein * 4 + fat * 9))
        let carbs = remainingKcal / 4
        return MacroNutrients(protein: protein, carbs: carbs, fat: fat)
    }

    /// Construit l'objectif complet à partir du profil. Si `activeEnergyKcal` fourni → TDEE précis.
    static func goal(profile: UserProfile, activeEnergyKcal: Double?) -> NutritionGoal {
        let bmrValue = bmr(sex: profile.sex,
                           weightKg: profile.weightKg,
                           heightCm: profile.heightCm,
                           age: profile.age)
        let tdeeValue: Double
        if let active = activeEnergyKcal {
            tdeeValue = tdee(bmr: bmrValue, activeEnergyKcal: active)
        } else {
            tdeeValue = tdee(bmr: bmrValue, activityLevel: profile.activityLevel)
        }
        let target = targetKcal(tdee: tdeeValue, bmr: bmrValue, sex: profile.sex, objective: profile.objective)
        let macroSplit = macros(weightKg: profile.weightKg, objective: profile.objective, targetKcal: target)
        return NutritionGoal(targetKcal: target,
                             macros: macroSplit,
                             objective: profile.objective,
                             tdee: tdeeValue,
                             bmr: bmrValue)
    }
}
