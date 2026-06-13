import SwiftUI

/// Anneau de progression d'un macronutriment (consommé / objectif).
struct MacroRingView: View {
    let title: String
    let consumed: Double
    let goal: Double
    let tint: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(consumed / goal, 1)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().stroke(tint.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(consumed))").font(.caption).bold()
            }
            .frame(width: 64, height: 64)
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text("/ \(Int(goal)) g").font(.caption2).foregroundStyle(.secondary)
        }
    }
}
