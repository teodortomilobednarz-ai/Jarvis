import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: SettingsViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let model { content(model) } else { ProgressView() }
            }
            .navigationTitle("Réglages")
            .task {
                if model == nil { model = SettingsViewModel(env: env) }
                await model?.load()
            }
        }
    }

    private func content(_ model: SettingsViewModel) -> some View {
        Form {
            if let profile = model.profile {
                Section("Profil") {
                    LabeledContent("Sexe", value: profile.sex.label)
                    LabeledContent("Âge", value: "\(profile.age) ans")
                    LabeledContent("Taille", value: "\(Int(profile.heightCm)) cm")
                    LabeledContent("Poids", value: "\(Int(profile.weightKg)) kg")
                    LabeledContent("Objectif", value: profile.objective.label)
                }
                Section("Objectif calculé") {
                    LabeledContent("BMR", value: "\(Int(model.goal.bmr)) kcal")
                    LabeledContent("TDEE", value: "\(Int(model.goal.tdee)) kcal")
                    LabeledContent("Cible", value: "\(Int(model.goal.targetKcal)) kcal")
                }
            }
            Section("Santé") {
                LabeledContent("Apple Santé", value: model.healthAvailable ? "Disponible" : "Indisponible")
                Button("Autoriser l'accès Santé") { Task { await model.requestHealthAuthorization() } }
            }
            Section("À propos") {
                Text("kcal-scan est un outil de suivi nutritionnel à visée informative, **non médical**.")
                    .font(.caption)
                Text("Application gratuite financée par la publicité. Aucun abonnement, aucun achat intégré.")
                    .font(.caption).foregroundStyle(.secondary)
                // TODO: liens Politique de confidentialité + Conditions (URLs à fournir).
            }
        }
    }
}

#Preview {
    SettingsView().environment(AppEnvironment.preview())
}
