import Foundation

/// État de consentement publicitaire : ATT (Apple) + RGPD/UMP (Google).
struct AdConsentState: Codable, Equatable {
    var attAuthorized: Bool
    var gdprConsentObtained: Bool

    /// Pub personnalisée possible uniquement si ATT autorisé ET consentement RGPD obtenu.
    var canRequestPersonalizedAds: Bool { attAuthorized && gdprConsentObtained }

    static let unknown = AdConsentState(attAuthorized: false, gdprConsentObtained: false)
}
