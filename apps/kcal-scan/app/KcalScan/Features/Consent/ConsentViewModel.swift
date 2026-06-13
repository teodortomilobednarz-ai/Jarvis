import Foundation
import Observation
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
#if canImport(UserMessagingPlatform)
import UserMessagingPlatform
#endif

@MainActor
@Observable
final class ConsentViewModel {
    private let env: AppEnvironment
    var state: AdConsentState = .unknown

    init(env: AppEnvironment) { self.env = env }

    /// Séquence RGPD/UMP (UE) puis ATT (Apple). Ordre recommandé : UMP avant ATT.
    func requestConsentFlow() async {
        let gdpr = await requestGDPRConsent()
        let att = await requestATT()
        state = AdConsentState(attAuthorized: att, gdprConsentObtained: gdpr)
        env.applyConsent(state)
    }

    private func requestATT() async -> Bool {
        #if canImport(AppTrackingTransparency)
        let status = await ATTrackingManager.requestTrackingAuthorization()
        return status == .authorized
        #else
        return false
        #endif
    }

    private func requestGDPRConsent() async -> Bool {
        #if canImport(UserMessagingPlatform)
        // TODO: configurer l'UMP (Google) : formulaire de consentement RGPD pour l'UE.
        // Charger et présenter le consent form si requis, puis retourner l'état obtenu.
        return true
        #else
        return true
        #endif
    }
}
