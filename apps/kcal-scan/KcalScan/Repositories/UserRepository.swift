import Foundation

/// Gère le profil utilisateur et calcule l'objectif nutritionnel (CloudKit + cache local).
@MainActor
final class UserRepository {
    private let cloud: CloudKitServiceProtocol
    private let health: HealthKitServiceProtocol
    private let local: LocalStore
    private let profileKey = "user_profile"

    private(set) var profile: UserProfile?

    init(cloud: CloudKitServiceProtocol, health: HealthKitServiceProtocol, local: LocalStore) {
        self.cloud = cloud
        self.health = health
        self.local = local
        self.profile = local.load(UserProfile.self, key: profileKey)
    }

    var hasProfile: Bool { profile != nil }

    func loadProfile() async -> UserProfile? {
        if let remote = try? await cloud.fetchProfile() {
            profile = remote
            local.save(remote, key: profileKey)
        }
        return profile
    }

    func save(_ newProfile: UserProfile) async throws {
        var updated = newProfile
        updated.updatedAt = Date()
        profile = updated
        local.save(updated, key: profileKey)   // offline d'abord
        try await cloud.saveProfile(updated)
    }

    /// Objectif du jour : TDEE précis via la dépense active HealthKit si disponible.
    func currentGoal() async -> NutritionGoal {
        guard let profile else { return .empty }
        let activeEnergy = try? await health.todayActiveEnergy()
        let active = (activeEnergy ?? 0) > 0 ? activeEnergy : nil
        return NutritionCalculator.goal(profile: profile, activeEnergyKcal: active)
    }
}
