import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Candidat aliment estimé par l'IA, avec indice de confiance et portion estimée.
struct FoodAnalysisCandidate: Identifiable, Hashable {
    let id = UUID()
    var foodItem: FoodItem
    var estimatedPortionGrams: Double
    var confidence: Double   // 0...1
}

enum VisionAnalysisError: Error, LocalizedError {
    case notConfigured
    case invalidImage
    case server(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Analyse photo non configurée (backend manquant)."
        case .invalidImage:  return "Image invalide."
        case .server(let m): return m
        }
    }
}

protocol VisionAnalysisServiceProtocol {
    var isConfigured: Bool { get }
    #if canImport(UIKit)
    func analyze(image: UIImage) async throws -> [FoodAnalysisCandidate]
    #endif
}

/// Implémentation mock — renvoie des candidats factices tant que le proxy backend n'existe pas.
/// IMPORTANT : la clé OpenAI ne doit JAMAIS être embarquée dans l'app.
/// L'appel réel doit passer par un proxy backend (voir `Config.visionEndpoint`).
final class MockVisionAnalysisService: VisionAnalysisServiceProtocol {
    var isConfigured: Bool { false }

    #if canImport(UIKit)
    func analyze(image: UIImage) async throws -> [FoodAnalysisCandidate] {
        try await Task.sleep(nanoseconds: 600_000_000)
        return [
            FoodAnalysisCandidate(
                foodItem: FoodItem(name: "Poulet grillé",
                                   per100g: MacroNutrients(protein: 27, carbs: 0, fat: 3),
                                   kcalPer100g: 135, source: .vision),
                estimatedPortionGrams: 150, confidence: 0.82),
            FoodAnalysisCandidate(
                foodItem: FoodItem(name: "Riz blanc cuit",
                                   per100g: MacroNutrients(protein: 2.7, carbs: 28, fat: 0.3),
                                   kcalPer100g: 130, source: .vision),
                estimatedPortionGrams: 200, confidence: 0.74),
            FoodAnalysisCandidate(
                foodItem: FoodItem(name: "Brocoli",
                                   per100g: MacroNutrients(protein: 2.8, carbs: 7, fat: 0.4),
                                   kcalPer100g: 34, source: .vision),
                estimatedPortionGrams: 80, confidence: 0.69)
        ]
    }
    #endif
}

/// Implémentation réelle — appelle un proxy backend qui détient la clé OpenAI.
/// TODO: implémenter le backend (serverless) qui reçoit l'image et appelle OpenAI Vision.
final class RemoteVisionAnalysisService: VisionAnalysisServiceProtocol {
    private let endpoint: URL?
    private let session: URLSession
    init(endpoint: URL?, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    var isConfigured: Bool { endpoint != nil }

    #if canImport(UIKit)
    func analyze(image: UIImage) async throws -> [FoodAnalysisCandidate] {
        guard let endpoint else { throw VisionAnalysisError.notConfigured }
        guard let jpeg = image.jpegData(compressionQuality: 0.7) else { throw VisionAnalysisError.invalidImage }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        // TODO: ajouter l'authentification du proxy (jeton court côté app), jamais la clé OpenAI.
        request.httpBody = jpeg

        let (data, response) = try await session.upload(for: request, from: jpeg)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw VisionAnalysisError.server("Réponse backend invalide.")
        }
        let dto = try JSONDecoder().decode(VisionResponseDTO.self, from: data)
        return dto.items.map { $0.toCandidate() }
    }
    #endif
}

// MARK: - DTO du proxy backend (format structuré attendu)

private struct VisionResponseDTO: Decodable {
    struct Item: Decodable {
        let name: String
        let portionGrams: Double
        let kcalPer100g: Double
        let proteinPer100g: Double
        let carbsPer100g: Double
        let fatPer100g: Double
        let confidence: Double

        func toCandidate() -> FoodAnalysisCandidate {
            FoodAnalysisCandidate(
                foodItem: FoodItem(name: name,
                                   per100g: MacroNutrients(protein: proteinPer100g,
                                                           carbs: carbsPer100g,
                                                           fat: fatPer100g),
                                   kcalPer100g: kcalPer100g,
                                   source: .vision),
                estimatedPortionGrams: portionGrams,
                confidence: confidence)
        }
    }
    let items: [Item]
}
