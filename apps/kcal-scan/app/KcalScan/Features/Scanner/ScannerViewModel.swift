import Foundation
import Observation

@MainActor
@Observable
final class ScannerViewModel {
    private let env: AppEnvironment

    enum State: Equatable {
        case scanning
        case loading
        case found(FoodItem)
        case notFound
        case error(String)
    }

    var state: State = .scanning
    var portionGrams: Double = 100
    var mealType: MealType = .lunch
    private var lastBarcode: String?

    init(env: AppEnvironment) { self.env = env }

    /// Appelé par le scanner. Aucune pub n'est déclenchée pendant le scan.
    func didScan(barcode: String) async {
        guard barcode != lastBarcode else { return }
        lastBarcode = barcode
        state = .loading
        do {
            let item = try await env.foodRepository.lookup(barcode: barcode)
            state = .found(item)
        } catch FoodLookupError.notFound {
            state = .notFound
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func reset() {
        state = .scanning
        lastBarcode = nil
    }

    /// Ajoute l'entrée puis autorise un interstitiel (action terminée, non critique).
    func confirm() async {
        guard case let .found(item) = state else { return }
        let entry = FoodEntry(mealType: mealType, foodItem: item, portionGrams: portionGrams, source: .openFoodFacts)
        try? await env.nutritionRepository.add(entry)
        env.ads.showInterstitial(for: .interstitialAfterEntry)
    }
}
