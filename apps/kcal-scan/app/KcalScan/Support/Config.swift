import Foundation

/// Configuration centrale. Aucune clé secrète ici : tout secret vit côté backend.
enum Config {
    /// Endpoint du proxy backend qui appelle OpenAI Vision (la clé OpenAI y reste).
    /// TODO: renseigner l'URL réelle du backend serverless. `nil` → service Vision en mode mock.
    static let visionEndpoint: URL? = nil

    /// Identifiant du conteneur iCloud/CloudKit.
    /// TODO: renseigner l'identifiant configuré dans les capabilities Xcode.
    static let cloudKitContainerIdentifier: String? = nil

    /// Active les publicités. (Toujours gratuit, financé par la pub — aucun achat intégré.)
    static let adsEnabled = true
}
