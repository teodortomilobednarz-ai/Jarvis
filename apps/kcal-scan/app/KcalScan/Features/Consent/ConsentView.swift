import SwiftUI

struct ConsentView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: ConsentViewModel?
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "hand.raised.fill").font(.system(size: 48)).foregroundStyle(.accent)
            Text("Confidentialité & publicité").font(.title2).bold()
            Text("kcal-scan est 100 % gratuite, financée par la publicité. Pour vous proposer des annonces et respecter le RGPD, nous demandons votre consentement. Vos données santé ne sont jamais utilisées à des fins publicitaires.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
            Button("Continuer") {
                Task {
                    await model?.requestConsentFlow()
                    onComplete()
                }
            }
            .buttonStyle(.borderedProminent)
            Button("Plus tard") { onComplete() }
                .font(.footnote)
        }
        .padding()
        .task { if model == nil { model = ConsentViewModel(env: env) } }
    }
}

#Preview {
    ConsentView(onComplete: {}).environment(AppEnvironment.preview())
}
