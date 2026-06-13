import SwiftUI

/// Routage racine : onboarding/consent si nécessaire, sinon TabView + bouton (+) flottant.
struct RootView: View {
    @Environment(AppEnvironment.self) private var env

    @State private var hasProfile = false
    @State private var didAskConsent = false
    @State private var showAddMenu = false
    @State private var addRoute: AddRoute?

    var body: some View {
        Group {
            if !hasProfile {
                OnboardingView { hasProfile = true }
            } else {
                mainTabs
            }
        }
        .task {
            hasProfile = env.userRepository.hasProfile
            if env.userRepository.profile == nil {
                hasProfile = (await env.userRepository.loadProfile()) != nil
            }
        }
        .fullScreenCover(isPresented: Binding(get: { !didAskConsent && hasProfile },
                                              set: { _ in didAskConsent = true })) {
            ConsentView { didAskConsent = true }
        }
    }

    private var mainTabs: some View {
        ZStack(alignment: .bottom) {
            TabView {
                DashboardView().tabItem { Label("Accueil", systemImage: "house.fill") }
                JournalView().tabItem { Label("Journal", systemImage: "book.fill") }
                ProgressDashboardView().tabItem { Label("Progrès", systemImage: "chart.line.uptrend.xyaxis") }
                SettingsView().tabItem { Label("Réglages", systemImage: "gearshape.fill") }
            }

            addButton
        }
        .confirmationDialog("Ajouter un aliment", isPresented: $showAddMenu, titleVisibility: .visible) {
            Button("Scanner un code-barres") { addRoute = .scanner }
            Button("Photo de l'assiette") { addRoute = .photo }
            Button("Recherche manuelle") { addRoute = .manual }
            Button("Annuler", role: .cancel) {}
        }
        .fullScreenCover(item: $addRoute) { route in
            switch route {
            case .scanner: ScannerView()
            case .photo:   PhotoAnalysisView()
            case .manual:  ManualSearchView()
            }
        }
    }

    private var addButton: some View {
        Button { showAddMenu = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color.accentColor))
                .shadow(radius: 4, y: 2)
        }
        .offset(y: -8)
        .accessibilityLabel("Ajouter un aliment")
    }
}

enum AddRoute: Identifiable {
    case scanner, photo, manual
    var id: Int { hashValue }
}

#Preview {
    RootView().environment(AppEnvironment.preview())
}
