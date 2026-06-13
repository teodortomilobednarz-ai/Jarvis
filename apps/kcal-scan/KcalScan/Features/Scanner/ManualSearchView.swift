import SwiftUI

/// Recherche manuelle d'aliments (Open Food Facts) avec ajout au journal.
struct ManualSearchView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var results: [FoodItem] = []
    @State private var isSearching = false
    @State private var selected: FoodItem?
    @State private var portionGrams: Double = 100
    @State private var mealType: MealType = .lunch

    var body: some View {
        NavigationStack {
            List {
                if let selected {
                    Section("Ajouter") {
                        Text(selected.name).font(.headline)
                        Stepper("\(Int(portionGrams)) g", value: $portionGrams, in: 10...1000, step: 10)
                        Picker("Repas", selection: $mealType) {
                            ForEach(MealType.allCases) { Text($0.label).tag($0) }
                        }
                        Button("Ajouter au journal") { Task { await add(selected) } }
                    }
                }
                Section("Résultats") {
                    if isSearching { ProgressView() }
                    ForEach(results) { item in
                        Button { selected = item } label: {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                Text("\(Int(item.kcalPer100g)) kcal / 100 g")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .searchable(text: $query)
            .onSubmit(of: .search) { Task { await search() } }
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Fermer") { dismiss() } } }
        }
    }

    private func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        defer { isSearching = false }
        results = (try? await env.foodRepository.search(query)) ?? []
    }

    private func add(_ item: FoodItem) async {
        let entry = FoodEntry(mealType: mealType, foodItem: item, portionGrams: portionGrams, source: .manual)
        try? await env.nutritionRepository.add(entry)
        env.ads.showInterstitial(for: .interstitialAfterEntry)
        dismiss()
    }
}

#Preview {
    ManualSearchView().environment(AppEnvironment.preview())
}
