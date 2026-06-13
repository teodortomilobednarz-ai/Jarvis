import SwiftUI

struct OnboardingView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: OnboardingViewModel?
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let model { form(model) } else { ProgressView() }
            }
            .navigationTitle("Bienvenue")
            .task { if model == nil { model = OnboardingViewModel(env: env) } }
        }
    }

    private func form(_ model: OnboardingViewModel) -> some View {
        Form {
            Section {
                Button("Importer depuis Apple Santé") { Task { await model.prefillFromHealth() } }
            }
            Section("Profil") {
                Picker("Sexe", selection: bind(model, \.sex)) {
                    ForEach(BiologicalSex.allCases) { Text($0.label).tag($0) }
                }
                DatePicker("Naissance", selection: bind(model, \.birthDate), displayedComponents: .date)
                Stepper("Taille : \(Int(model.heightCm)) cm", value: bind(model, \.heightCm), in: 120...230)
                Stepper("Poids : \(Int(model.weightKg)) kg", value: bind(model, \.weightKg), in: 30...250)
            }
            Section("Activité & objectif") {
                Picker("Activité", selection: bind(model, \.activityLevel)) {
                    ForEach(ActivityLevel.allCases) { Text($0.label).tag($0) }
                }
                Picker("Objectif", selection: bind(model, \.objective)) {
                    ForEach(NutritionObjective.allCases) { Text($0.label).tag($0) }
                }
            }
            Section("Estimation") {
                LabeledContent("Cible", value: "\(Int(model.previewGoal.targetKcal)) kcal")
                LabeledContent("Protéines", value: "\(Int(model.previewGoal.macros.protein)) g")
                LabeledContent("Glucides", value: "\(Int(model.previewGoal.macros.carbs)) g")
                LabeledContent("Lipides", value: "\(Int(model.previewGoal.macros.fat)) g")
            }
            Section {
                Button("Commencer") {
                    Task { if await model.save() { onComplete() } }
                }
                .disabled(model.isSaving)
                Text("Outil de suivi nutritionnel, non médical.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func bind<T>(_ model: OnboardingViewModel, _ keyPath: ReferenceWritableKeyPath<OnboardingViewModel, T>) -> Binding<T> {
        Binding(get: { model[keyPath: keyPath] }, set: { model[keyPath: keyPath] = $0 })
    }
}

#Preview {
    OnboardingView(onComplete: {}).environment(AppEnvironment.preview())
}
