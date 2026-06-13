import SwiftUI

@main
struct KcalScanApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .task {
                    // Autorisations santé + chargement initial du profil.
                    try? await environment.health.requestAuthorization()
                    _ = await environment.userRepository.loadProfile()
                }
        }
    }
}
