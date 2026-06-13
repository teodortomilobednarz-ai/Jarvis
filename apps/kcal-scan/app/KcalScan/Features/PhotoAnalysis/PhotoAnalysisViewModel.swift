import Foundation
import Observation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
@Observable
final class PhotoAnalysisViewModel {
    private let env: AppEnvironment

    enum State: Equatable {
        case idle
        case analyzing
        case results([FoodAnalysisCandidate])
        case error(String)
    }

    var state: State = .idle
    var mealType: MealType = .lunch
    var selected: Set<UUID> = []

    init(env: AppEnvironment) { self.env = env }

    var isMock: Bool { !env.foodRepository.visionConfigured }

    #if canImport(UIKit)
    /// Analyse la photo. Aucune pub pendant l'analyse.
    func analyze(_ image: UIImage) async {
        state = .analyzing
        do {
            let candidates = try await env.foodRepository.analyze(image: image)
            selected = Set(candidates.map(\.id))
            state = .results(candidates)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    #endif

    func toggle(_ candidate: FoodAnalysisCandidate) {
        if selected.contains(candidate.id) { selected.remove(candidate.id) }
        else { selected.insert(candidate.id) }
    }

    /// Ajoute les candidats sélectionnés, puis autorise un interstitiel (action terminée).
    func confirm() async {
        guard case let .results(candidates) = state else { return }
        for candidate in candidates where selected.contains(candidate.id) {
            let entry = FoodEntry(mealType: mealType,
                                  foodItem: candidate.foodItem,
                                  portionGrams: candidate.estimatedPortionGrams,
                                  source: .vision)
            try? await env.nutritionRepository.add(entry)
        }
        env.ads.showInterstitial(for: .interstitialAfterEntry)
    }
}
