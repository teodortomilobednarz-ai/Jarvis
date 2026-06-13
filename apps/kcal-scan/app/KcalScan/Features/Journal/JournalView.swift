import SwiftUI

struct JournalView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: JournalViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    List {
                        ForEach(MealType.allCases) { meal in
                            Section(meal.label) {
                                let items = model.entries(for: meal)
                                if items.isEmpty {
                                    Text("Aucun aliment").foregroundStyle(.secondary).font(.caption)
                                } else {
                                    ForEach(items) { entry in
                                        EntryRow(entry: entry)
                                            .swipeActions {
                                                Button("Supprimer", role: .destructive) {
                                                    Task { await model.delete(entry) }
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { Task { await model?.changeDay(by: -1) } } label: { Image(systemName: "chevron.left") }
                }
                ToolbarItem(placement: .principal) {
                    Text(model?.day ?? Date(), style: .date).font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { Task { await model?.changeDay(by: 1) } } label: { Image(systemName: "chevron.right") }
                }
            }
            .safeAreaInset(edge: .bottom) { AdBannerView(placement: .journalBanner) }
            .task {
                if model == nil { model = JournalViewModel(env: env) }
                await model?.load()
            }
        }
    }
}

private struct EntryRow: View {
    let entry: FoodEntry
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.foodItem.name).font(.body)
                Text("\(Int(entry.portionGrams)) g").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(entry.kcal)) kcal").font(.subheadline).bold()
        }
    }
}

#Preview {
    JournalView().environment(AppEnvironment.preview())
}
