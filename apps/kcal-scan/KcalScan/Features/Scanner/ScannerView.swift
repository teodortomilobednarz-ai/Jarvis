import SwiftUI

struct ScannerView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var model: ScannerViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    switch model.state {
                    case .scanning:
                        BarcodeScannerView { code in Task { await model.didScan(barcode: code) } }
                            .ignoresSafeArea()
                    case .loading:
                        ProgressView("Recherche du produit…")
                    case .found(let item):
                        foundView(model, item)
                    case .notFound:
                        message("Produit introuvable", retry: model)
                    case .error(let msg):
                        message(msg, retry: model)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") { dismiss() }
                }
            }
            .task { if model == nil { model = ScannerViewModel(env: env) } }
        }
    }

    private func foundView(_ model: ScannerViewModel, _ item: FoodItem) -> some View {
        Form {
            Section("Produit") {
                Text(item.name).font(.headline)
                if let brand = item.brand { Text(brand).foregroundStyle(.secondary) }
                Text("\(Int(item.kcalPer100g)) kcal / 100 g")
            }
            Section("Portion") {
                Stepper("\(Int(model.portionGrams)) g", value: Binding(
                    get: { model.portionGrams }, set: { model.portionGrams = $0 }),
                        in: 10...1000, step: 10)
                Picker("Repas", selection: Binding(
                    get: { model.mealType }, set: { model.mealType = $0 })) {
                    ForEach(MealType.allCases) { Text($0.label).tag($0) }
                }
            }
            Section {
                Button("Ajouter au journal") {
                    Task { await model.confirm(); dismiss() }
                }
            }
        }
    }

    private func message(_ text: String, retry model: ScannerViewModel) -> some View {
        VStack(spacing: 16) {
            Text(text).multilineTextAlignment(.center)
            Button("Réessayer") { model.reset() }
        }
        .padding()
    }
}

#Preview {
    ScannerView().environment(AppEnvironment.preview())
}
