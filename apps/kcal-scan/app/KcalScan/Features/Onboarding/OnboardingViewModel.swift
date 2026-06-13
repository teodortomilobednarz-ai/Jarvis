import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private let env: AppEnvironment

    var sex: BiologicalSex = .male
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    var heightCm: Double = 175
    var weightKg: Double = 75
    var activityLevel: ActivityLevel = .moderate
    var objective: NutritionObjective = .maintenance
    var isSaving = false

    init(env: AppEnvironment) { self.env = env }

    /// Pré-remplit depuis HealthKit si l'utilisateur a accordé l'accès.
    func prefillFromHealth() async {
        try? await env.health.requestAuthorization()
        let snapshot = await env.health.snapshot()
        if let s = snapshot.sex { sex = s }
        if let d = snapshot.birthDate { birthDate = d }
        if let h = snapshot.heightCm, h > 0 { heightCm = h }
        if let w = snapshot.bodyMassKg, w > 0 { weightKg = w }
    }

    var previewGoal: NutritionGoal {
        let profile = buildProfile()
        return NutritionCalculator.goal(profile: profile, activeEnergyKcal: nil)
    }

    func save() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            try await env.userRepository.save(buildProfile())
            return true
        } catch {
            return false
        }
    }

    private func buildProfile() -> UserProfile {
        UserProfile(sex: sex, birthDate: birthDate, heightCm: heightCm, weightKg: weightKg,
                    activityLevel: activityLevel, objective: objective)
    }
}
