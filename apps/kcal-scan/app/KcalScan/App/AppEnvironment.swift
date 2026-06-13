import Foundation
import Observation

/// Conteneur d'injection de dépendances : instancie services + repositories.
@MainActor
@Observable
final class AppEnvironment {
    let health: HealthKitServiceProtocol
    let cloud: CloudKitServiceProtocol
    let ads: AdsService

    let userRepository: UserRepository
    let foodRepository: FoodRepository
    let nutritionRepository: NutritionRepository

    var consent: AdConsentState = .unknown

    init(health: HealthKitServiceProtocol,
         cloud: CloudKitServiceProtocol,
         off: OpenFoodFactsServiceProtocol,
         vision: VisionAnalysisServiceProtocol,
         ads: AdsService) {
        let local = LocalStore()
        self.health = health
        self.cloud = cloud
        self.ads = ads
        self.userRepository = UserRepository(cloud: cloud, health: health, local: local)
        self.foodRepository = FoodRepository(off: off, vision: vision)
        self.nutritionRepository = NutritionRepository(cloud: cloud, health: health, local: local)
    }

    /// Composition de production.
    static func live() -> AppEnvironment {
        let vision: VisionAnalysisServiceProtocol = Config.visionEndpoint == nil
            ? MockVisionAnalysisService()
            : RemoteVisionAnalysisService(endpoint: Config.visionEndpoint)
        let ads: AdsService = Config.adsEnabled ? AdMobAdsService() : NoopAdsService()
        return AppEnvironment(
            health: HealthKitService(),
            cloud: CloudKitService(containerIdentifier: Config.cloudKitContainerIdentifier),
            off: OpenFoodFactsService(),
            vision: vision,
            ads: ads
        )
    }

    /// Composition pour previews/tests (sans réseau ni SDK pub).
    static func preview() -> AppEnvironment {
        AppEnvironment(
            health: HealthKitService(),
            cloud: CloudKitService(),
            off: OpenFoodFactsService(),
            vision: MockVisionAnalysisService(),
            ads: NoopAdsService()
        )
    }

    func applyConsent(_ state: AdConsentState) {
        consent = state
        ads.configure(consent: state)
    }
}
