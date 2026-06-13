import SwiftUI
import Charts

/// Nommé `ProgressDashboardView` pour éviter la collision avec `SwiftUI.ProgressView`.
struct ProgressDashboardView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: ProgressViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let model, !model.points.isEmpty {
                    Chart(model.points) { point in
                        BarMark(x: .value("Jour", point.date, unit: .day),
                                y: .value("kcal", point.consumedKcal))
                        .foregroundStyle(Color.accentColor)
                        RuleMark(y: .value("Objectif", point.targetKcal))
                            .foregroundStyle(.secondary)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                    .padding()
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Progrès")
            .safeAreaInset(edge: .bottom) { AdBannerView(placement: .progressBanner) }
            .task {
                if model == nil { model = ProgressViewModel(env: env) }
                await model?.load()
            }
        }
    }
}

#Preview {
    ProgressDashboardView().environment(AppEnvironment.preview())
}
