import Foundation

/// Journal alimentaire : entrées du jour (CloudKit + cache local) et synthèse quotidienne.
@MainActor
final class NutritionRepository {
    private let cloud: CloudKitServiceProtocol
    private let health: HealthKitServiceProtocol
    private let local: LocalStore

    init(cloud: CloudKitServiceProtocol, health: HealthKitServiceProtocol, local: LocalStore) {
        self.cloud = cloud
        self.health = health
        self.local = local
    }

    private func cacheKey(for day: Date) -> String {
        "entries_" + Self.dayFormatter.string(from: day)
    }

    func entries(on day: Date) async -> [FoodEntry] {
        let cached = local.load([FoodEntry].self, key: cacheKey(for: day)) ?? []
        if let remote = try? await cloud.fetchEntries(on: day) {
            local.save(remote, key: cacheKey(for: day))
            return remote
        }
        return cached
    }

    func add(_ entry: FoodEntry) async throws {
        var cached = local.load([FoodEntry].self, key: cacheKey(for: entry.date)) ?? []
        cached.append(entry)
        local.save(cached, key: cacheKey(for: entry.date))   // offline d'abord
        try await cloud.saveEntry(entry)
    }

    func delete(_ entry: FoodEntry) async throws {
        var cached = local.load([FoodEntry].self, key: cacheKey(for: entry.date)) ?? []
        cached.removeAll { $0.id == entry.id }
        local.save(cached, key: cacheKey(for: entry.date))
        try await cloud.deleteEntry(id: entry.id)
    }

    /// Synthèse d'une journée = entrées + pas/énergie active HealthKit + objectif.
    func summary(on day: Date, goal: NutritionGoal) async -> DailyNutritionSummary {
        let entries = await entries(on: day)
        let snapshot = await health.snapshot()
        return DailyNutritionSummary(date: day,
                                     entries: entries,
                                     steps: snapshot.steps,
                                     activeEnergyKcal: snapshot.activeEnergyKcal,
                                     goal: goal)
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
