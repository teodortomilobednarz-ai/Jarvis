import Foundation
import Observation

@MainActor
@Observable
final class ProgressViewModel {
    private let env: AppEnvironment

    struct DayPoint: Identifiable {
        let id = UUID()
        let date: Date
        let consumedKcal: Double
        let targetKcal: Double
    }

    var points: [DayPoint] = []
    var isLoading = false

    init(env: AppEnvironment) { self.env = env }

    /// Tendance calorique des 7 derniers jours. TODO: ajouter l'historique de poids (HealthKit samples).
    func load() async {
        isLoading = true
        defer { isLoading = false }
        let goal = await env.userRepository.currentGoal()
        var result: [DayPoint] = []
        for offset in stride(from: 6, through: 0, by: -1) {
            guard let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let summary = await env.nutritionRepository.summary(on: day, goal: goal)
            result.append(DayPoint(date: day, consumedKcal: summary.consumedKcal, targetKcal: goal.targetKcal))
        }
        points = result
    }
}
