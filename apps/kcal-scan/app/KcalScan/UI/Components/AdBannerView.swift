import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Bannière publicitaire discrète. Affichée uniquement sur Dashboard / Journal / Progress.
/// Ne jamais utiliser sur Scanner / PhotoAnalysis.
struct AdBannerView: View {
    @Environment(AppEnvironment.self) private var env
    let placement: AdPlacement

    var body: some View {
        if env.ads.bannersEnabled {
            BannerContainer(unitID: env.ads.bannerUnitID(for: placement))
                .frame(height: 50)
        } else {
            EmptyView()
        }
    }
}

#if canImport(GoogleMobileAds) && canImport(UIKit)
private struct BannerContainer: UIViewRepresentable {
    let unitID: String

    func makeUIView(context: Context) -> UIView {
        // TODO: instancier un GADBannerView, lui assigner l'unitID et le rootViewController,
        // puis charger une GADRequest. Vérifier les noms de symboles selon la version du SDK.
        UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#else
private struct BannerContainer: View {
    let unitID: String
    var body: some View { Color.clear }
}
#endif
