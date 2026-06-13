import SwiftUI

struct DashboardView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: DashboardViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let model {
                        CalorieRemainingView(remaining: model.remainingKcal,
                                             target: model.targetKcal,
                                             consumed: model.consumedKcal,
                                             steps: model.steps)
                        macroRings(model)
                    } else {
                        ProgressView().padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("Accueil")
            .safeAreaInset(edge: .bottom) { AdBannerView(placement: .dashboardBanner) }
            .task {
                if model == nil { model = DashboardViewModel(env: env) }
                await model?.load()
            }
            .refreshable { await model?.load() }
        }
    }

    private func macroRings(_ model: DashboardViewModel) -> some View {
        HStack(spacing: 20) {
            MacroRingView(title: "Protéines", consumed: model.consumedMacros.protein,
                          goal: model.goalMacros.protein, tint: .blue)
            MacroRingView(title: "Glucides", consumed: model.consumedMacros.carbs,
                          goal: model.goalMacros.carbs, tint: .orange)
            MacroRingView(title: "Lipides", consumed: model.consumedMacros.fat,
                          goal: model.goalMacros.fat, tint: .pink)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    DashboardView().environment(AppEnvironment.preview())
}
