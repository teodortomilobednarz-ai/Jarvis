import Foundation

/// Emplacements publicitaires de l'app. Jamais d'emplacement sur Scanner / PhotoAnalysis.
enum AdPlacement: String, Codable, CaseIterable, Identifiable {
    case dashboardBanner
    case journalBanner
    case progressBanner
    case interstitialAfterEntry

    var id: String { rawValue }

    var isBanner: Bool { self != .interstitialAfterEntry }
    var isInterstitial: Bool { self == .interstitialAfterEntry }
}
