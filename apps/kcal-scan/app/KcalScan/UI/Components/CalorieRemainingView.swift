import SwiftUI

/// Carte « calories restantes aujourd'hui ».
struct CalorieRemainingView: View {
    let remaining: Int
    let target: Int
    let consumed: Int
    let steps: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("Restant aujourd'hui").font(.subheadline).foregroundStyle(.secondary)
            Text("\(remaining)").font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(remaining >= 0 ? Color.primary : Color.red)
            Text("kcal").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 16) {
                stat("Objectif", "\(target)")
                stat("Consommé", "\(consumed)")
                stat("Pas", "\(steps)")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack {
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}
