import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let env: AppEnvironment

    var profile: UserProfile?
    var goal: NutritionGoal = .empty
    var healthAvailable: Bool { env.health.isAvailable }

    init(env: AppEnvironment) {
        self.env = env
        self.profile = env.userRepository.profile
    }

    func load() async {
        profile = await env.userRepository.loadProfile()
        goal = await env.userRepository.currentGoal()
    }

    func save(_ updated: UserProfile) async {
        try? await env.userRepository.save(updated)
        profile = updated
        goal = await env.userRepository.currentGoal()
    }

    func requestHealthAuthorization() async {
        try? await env.health.requestAuthorization()
    }
}
