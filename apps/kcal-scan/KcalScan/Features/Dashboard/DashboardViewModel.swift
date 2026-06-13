import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private let env: AppEnvironment

    var summary: DailyNutritionSummary = .empty()
    var isLoading = false

    init(env: AppEnvironment) { self.env = env }

    var remainingKcal: Int { Int(summary.remainingKcal.rounded()) }
    var targetKcal: Int { Int(summary.goal.targetKcal.rounded()) }
    var consumedKcal: Int { Int(summary.consumedKcal.rounded()) }
    var steps: Int { summary.steps }
    var consumedMacros: MacroNutrients { summary.consumedMacros }
    var goalMacros: MacroNutrients { summary.goal.macros }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        let goal = await env.userRepository.currentGoal()
        summary = await env.nutritionRepository.summary(on: Date(), goal: goal)
    }
}
