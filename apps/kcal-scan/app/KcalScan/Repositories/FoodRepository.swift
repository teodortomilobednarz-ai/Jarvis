import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Recherche d'aliments : code-barres (Open Food Facts), photo (Vision IA), recherche texte.
@MainActor
final class FoodRepository {
    private let off: OpenFoodFactsServiceProtocol
    private let vision: VisionAnalysisServiceProtocol

    init(off: OpenFoodFactsServiceProtocol, vision: VisionAnalysisServiceProtocol) {
        self.off = off
        self.vision = vision
    }

    func lookup(barcode: String) async throws -> FoodItem {
        try await off.product(barcode: barcode)
    }

    func search(_ query: String) async throws -> [FoodItem] {
        try await off.search(query: query)
    }

    var visionConfigured: Bool { vision.isConfigured }

    #if canImport(UIKit)
    func analyze(image: UIImage) async throws -> [FoodAnalysisCandidate] {
        try await vision.analyze(image: image)
    }
    #endif
}
