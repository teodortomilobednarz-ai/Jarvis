import Foundation

/// Abstraction publicitaire : permet de changer de régie sans toucher l'UI.
@MainActor
protocol AdsService: AnyObject {
    /// Applique l'état de consentement (ATT + RGPD) avant tout chargement.
    func configure(consent: AdConsentState)

    /// Précharge un interstitiel pour l'emplacement donné (non critique).
    func preloadInterstitial(for placement: AdPlacement)

    /// Affiche un interstitiel si la fréquence le permet. Renvoie `true` si affiché.
    /// Ne fait JAMAIS rien pendant scan/analyse photo (aucun appel depuis ces écrans).
    @discardableResult
    func showInterstitial(for placement: AdPlacement) -> Bool

    /// Indique si les bannières peuvent être affichées (consentement obtenu, SDK prêt).
    var bannersEnabled: Bool { get }

    /// Identifiant d'unité publicitaire pour une bannière (TODO: IDs AdMob réels).
    func bannerUnitID(for placement: AdPlacement) -> String
}

/// Implémentation neutre (previews, tests, ou tant que la régie n'est pas branchée).
@MainActor
final class NoopAdsService: AdsService {
    func configure(consent: AdConsentState) {}
    func preloadInterstitial(for placement: AdPlacement) {}
    func showInterstitial(for placement: AdPlacement) -> Bool { false }
    var bannersEnabled: Bool { false }
    func bannerUnitID(for placement: AdPlacement) -> String { "" }
}

/// Cap de fréquence des interstitiels (logique réutilisable, indépendante de la régie).
struct InterstitialFrequencyCap {
    /// Délai minimal entre deux interstitiels.
    var minimumInterval: TimeInterval = 180
    private var lastShown: Date?

    mutating func canShow(now: Date = Date()) -> Bool {
        guard let last = lastShown else { return true }
        return now.timeIntervalSince(last) >= minimumInterval
    }

    mutating func markShown(now: Date = Date()) { lastShown = now }
}
