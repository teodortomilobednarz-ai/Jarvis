import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Implémentation AdMob. Compile avec ou sans le SDK (guarde `canImport(GoogleMobileAds)`).
/// TODO Xcode :
///  - Ajouter le package SPM Google Mobile Ads (vérifier la dernière version et les noms de symboles).
///  - Renseigner `GADApplicationIdentifier` dans Info.plist.
///  - Remplacer les ad unit IDs de test par les IDs de production.
@MainActor
final class AdMobAdsService: AdsService {
    private var consent: AdConsentState = .unknown
    private var cap = InterstitialFrequencyCap()

    // TODO: remplacer par les vrais ad unit IDs AdMob (ceux-ci sont les IDs de TEST Google).
    private let testBannerUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let testInterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"

    func configure(consent: AdConsentState) {
        self.consent = consent
        #if canImport(GoogleMobileAds)
        // TODO: initialiser le SDK une seule fois au lancement (MobileAds start) et
        // propager le consentement RGPD/UMP + le mode non personnalisé si refusé.
        #endif
    }

    var bannersEnabled: Bool {
        #if canImport(GoogleMobileAds)
        return true
        #else
        return false
        #endif
    }

    func bannerUnitID(for placement: AdPlacement) -> String {
        // TODO: mapper chaque placement vers son ad unit ID de production.
        testBannerUnitID
    }

    func preloadInterstitial(for placement: AdPlacement) {
        #if canImport(GoogleMobileAds)
        // TODO: charger un GADInterstitialAd avec `testInterstitialUnitID`/ID prod et le mettre en cache.
        _ = testInterstitialUnitID
        #endif
    }

    @discardableResult
    func showInterstitial(for placement: AdPlacement) -> Bool {
        guard placement.isInterstitial else { return false }
        guard cap.canShow() else { return false }
        #if canImport(GoogleMobileAds)
        // TODO: présenter l'interstitiel préchargé depuis le rootViewController.
        cap.markShown()
        return true
        #else
        return false
        #endif
    }
}
