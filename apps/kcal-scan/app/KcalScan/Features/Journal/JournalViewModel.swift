import Foundation
import Observation

@MainActor
@Observable
final class JournalViewModel {
    private let env: AppEnvironment

    var day: Date = Date()
    var entries: [FoodEntry] = []
    var isLoading = false

    init(env: AppEnvironment) { self.env = env }

    func entries(for meal: MealType) -> [FoodEntry] {
        entries.filter { $0.mealType == meal }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        entries = await env.nutritionRepository.entries(on: day)
    }

    func delete(_ entry: FoodEntry) async {
        try? await env.nutritionRepository.delete(entry)
        await load()
    }

    func changeDay(by days: Int) async {
        day = Calendar.current.date(byAdding: .day, value: days, to: day) ?? day
        await load()
    }
}
