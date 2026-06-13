import SwiftUI
import PhotosUI
import UIKit

struct PhotoAnalysisView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var model: PhotoAnalysisViewModel?
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    content(model)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Fermer") { dismiss() } }
            }
            .task { if model == nil { model = PhotoAnalysisViewModel(env: env) } }
            .onChange(of: pickerItem) { _, newValue in
                guard let newValue, let model else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await model.analyze(image)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func content(_ model: PhotoAnalysisViewModel) -> some View {
        switch model.state {
        case .idle:
            VStack(spacing: 16) {
                if model.isMock {
                    Label("Mode démo (analyse IA non branchée)", systemImage: "exclamationmark.triangle")
                        .font(.caption).foregroundStyle(.orange)
                }
                PhotosPicker("Choisir une photo d'assiette", selection: $pickerItem, matching: .images)
                    .buttonStyle(.borderedProminent)
                disclaimer
            }
            .padding()
        case .analyzing:
            ProgressView("Analyse en cours…")
        case .results(let candidates):
            resultsList(model, candidates)
        case .error(let msg):
            VStack(spacing: 12) {
                Text(msg).multilineTextAlignment(.center)
                PhotosPicker("Réessayer", selection: $pickerItem, matching: .images)
            }.padding()
        }
    }

    private func resultsList(_ model: PhotoAnalysisViewModel, _ candidates: [FoodAnalysisCandidate]) -> some View {
        Form {
            Section {
                Picker("Repas", selection: Binding(
                    get: { model.mealType }, set: { model.mealType = $0 })) {
                    ForEach(MealType.allCases) { Text($0.label).tag($0) }
                }
            }
            Section("Aliments détectés") {
                ForEach(candidates) { candidate in
                    Button { model.toggle(candidate) } label: {
                        HStack {
                            Image(systemName: model.selected.contains(candidate.id) ? "checkmark.circle.fill" : "circle")
                            VStack(alignment: .leading) {
                                Text(candidate.foodItem.name)
                                Text("\(Int(candidate.estimatedPortionGrams)) g · conf. \(Int(candidate.confidence * 100)) %")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(Int(candidate.foodItem.kcalPer100g * candidate.estimatedPortionGrams / 100)) kcal")
                        }
                    }
                    .tint(.primary)
                }
            }
            Section {
                Button("Ajouter au journal") { Task { await model.confirm(); dismiss() } }
                disclaimer
            }
        }
    }

    private var disclaimer: some View {
        Text("Les estimations IA sont indicatives et peuvent être inexactes. Ajustez si nécessaire.")
            .font(.caption2).foregroundStyle(.secondary)
    }
}

#Preview {
    PhotoAnalysisView().environment(AppEnvironment.preview())
}
