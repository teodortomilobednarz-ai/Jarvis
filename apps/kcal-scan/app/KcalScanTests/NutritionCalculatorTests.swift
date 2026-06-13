import XCTest
@testable import KcalScan

final class NutritionCalculatorTests: XCTestCase {

    func testBMRMaleMifflin() {
        // H, 80 kg, 180 cm, 30 ans → 10*80 + 6.25*180 - 5*30 + 5 = 1780
        let bmr = NutritionCalculator.bmr(sex: .male, weightKg: 80, heightCm: 180, age: 30)
        XCTAssertEqual(bmr, 1780, accuracy: 0.001)
    }

    func testBMRFemaleMifflin() {
        // F, 60 kg, 165 cm, 30 ans → 600 + 1031.25 - 150 - 161 = 1320.25
        let bmr = NutritionCalculator.bmr(sex: .female, weightKg: 60, heightCm: 165, age: 30)
        XCTAssertEqual(bmr, 1320.25, accuracy: 0.001)
    }

    func testTDEEPreciseAddsActiveEnergy() {
        let tdee = NutritionCalculator.tdee(bmr: 1780, activeEnergyKcal: 500)
        XCTAssertEqual(tdee, 1780 * 1.2 + 500, accuracy: 0.001)
    }

    func testTDEEFallbackUsesPAL() {
        let tdee = NutritionCalculator.tdee(bmr: 1780, activityLevel: .moderate)
        XCTAssertEqual(tdee, 1780 * 1.55, accuracy: 0.001)
    }

    func testTargetRespectsFloor() {
        // Objectif sèche avec TDEE faible → ne descend pas sous le BMR.
        let target = NutritionCalculator.targetKcal(tdee: 1600, bmr: 1700, sex: .male, objective: .cut)
        XCTAssertGreaterThanOrEqual(target, 1700)
    }

    func testMacrosCoverTargetCalories() {
        let target = 2200.0
        let macros = NutritionCalculator.macros(weightKg: 80, objective: .maintenance, targetKcal: target)
        XCTAssertEqual(macros.kcal, target, accuracy: 1.0)
        XCTAssertEqual(macros.protein, 80 * 1.8, accuracy: 0.001)
    }
}
