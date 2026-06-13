import Foundation

enum FoodLookupError: Error, LocalizedError {
    case notFound
    case network(Error)
    case decoding

    var errorDescription: String? {
        switch self {
        case .notFound: return "Produit introuvable."
        case .network:  return "Erreur réseau."
        case .decoding: return "Données illisibles."
        }
    }
}

protocol OpenFoodFactsServiceProtocol {
    func product(barcode: String) async throws -> FoodItem
    func search(query: String) async throws -> [FoodItem]
}

/// Accès à l'API publique Open Food Facts (gratuite).
final class OpenFoodFactsService: OpenFoodFactsServiceProtocol {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func product(barcode: String) async throws -> FoodItem {
        let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        let response: OFFProductResponse = try await get(url)
        guard response.status == 1, let product = response.product else { throw FoodLookupError.notFound }
        return product.toFoodItem(barcode: barcode)
    }

    func search(query: String) async throws -> [FoodItem] {
        var components = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")!
        components.queryItems = [
            .init(name: "search_terms", value: query),
            .init(name: "search_simple", value: "1"),
            .init(name: "action", value: "process"),
            .init(name: "json", value: "1"),
            .init(name: "page_size", value: "20")
        ]
        let response: OFFSearchResponse = try await get(components.url!)
        return (response.products ?? []).compactMap { $0.toFoodItemIfValid() }
    }

    private func get<T: Decodable>(_ url: URL) async throws -> T {
        do {
            let (data, _) = try await session.data(from: url)
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw FoodLookupError.decoding }
        } catch let error as FoodLookupError {
            throw error
        } catch {
            throw FoodLookupError.network(error)
        }
    }
}

// MARK: - DTO

private struct OFFProductResponse: Decodable {
    let status: Int
    let product: OFFProduct?
}

private struct OFFSearchResponse: Decodable {
    let products: [OFFProduct]?
}

private struct OFFProduct: Decodable {
    let product_name: String?
    let brands: String?
    let code: String?
    let nutriments: OFFNutriments?

    func toFoodItem(barcode: String) -> FoodItem {
        let n = nutriments
        return FoodItem(
            name: product_name?.isEmpty == false ? product_name! : "Produit \(barcode)",
            brand: brands,
            barcode: barcode,
            per100g: MacroNutrients(protein: n?.proteins_100g ?? 0,
                                    carbs: n?.carbohydrates_100g ?? 0,
                                    fat: n?.fat_100g ?? 0),
            kcalPer100g: n?.energyKcal100g ?? 0,
            source: .openFoodFacts
        )
    }

    func toFoodItemIfValid() -> FoodItem? {
        guard let name = product_name, !name.isEmpty else { return nil }
        return toFoodItem(barcode: code ?? "")
    }
}

private struct OFFNutriments: Decodable {
    let proteins_100g: Double?
    let carbohydrates_100g: Double?
    let fat_100g: Double?
    let energyKcal100g: Double?

    enum CodingKeys: String, CodingKey {
        case proteins_100g, carbohydrates_100g, fat_100g
        case energyKcal100g = "energy-kcal_100g"
    }
}
