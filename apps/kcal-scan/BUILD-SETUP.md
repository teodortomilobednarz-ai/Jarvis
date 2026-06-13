# kcal-scan — Configuration Xcode & build

Le code de `KcalScan/` est un **squelette SwiftUI** prêt à intégrer dans un projet Xcode.
Il ne peut pas être compilé hors de Xcode (frameworks Apple : HealthKit, CloudKit, VisionKit…).

## 1. Créer le projet
1. Xcode → New Project → **App** (iOS), SwiftUI, langage Swift.
2. Nom de produit : `KcalScan`. Cible minimale : **iOS 17**.
3. Supprimer le `ContentView.swift`/`App` générés, puis glisser le dossier `KcalScan/` (et `KcalScanTests/`) dans le projet.

## 2. Capabilities à activer (target → Signing & Capabilities)
- **HealthKit**
- **iCloud** → cocher **CloudKit**, créer le conteneur `iCloud.com.<votre-domaine>.kcalscan`
- **Sign in with Apple**
- **Background Modes** → Remote notifications (pour les souscriptions CloudKit)
- **Push Notifications** (CloudKit)

Mettre à jour `Config.cloudKitContainerIdentifier` et l'entitlement avec l'identifiant réel.

## 3. Info.plist
Fusionner les clés de `KcalScan/Resources/Info-additions.plist` (usage Santé, caméra, photo, ATT, `GADApplicationIdentifier`).

## 4. Packages (SPM)
- **Google Mobile Ads SDK** : `https://github.com/googleads/swift-package-manager-google-mobile-ads`
  - ⚠️ Vérifier la **dernière version** et les **noms de symboles** (l'API AdMob a changé récemment : `GADBannerView`/`BannerView`, init de `MobileAds`…). Compléter les `TODO` dans `AdMobAdsService.swift` et `AdBannerView.swift`.
  - L'**UMP** (User Messaging Platform, consentement RGPD) est inclus avec le SDK.
- Aucun autre package tiers. HealthKit, CloudKit, VisionKit, PhotosUI, Charts, AppTrackingTransparency, AuthenticationServices = frameworks Apple.

> Le code utilise `#if canImport(GoogleMobileAds)` : il **compile même sans** le package (pub désactivée). Ajouter le package active la pub.

## 5. Backend analyse photo (Vision IA)
- `MockVisionAnalysisService` est utilisé tant que `Config.visionEndpoint == nil` (données factices).
- Pour la prod : déployer un **proxy serverless** qui reçoit l'image, appelle **OpenAI Vision** (la clé y reste) et renvoie le JSON structuré attendu par `RemoteVisionAnalysisService` (`VisionResponseDTO`). Renseigner ensuite `Config.visionEndpoint`.

## 6. À vérifier dans Xcode (non vérifiable hors Xcode)
- Symboles HealthKit (`HKStatisticsQuery`, `requestAuthorization(toShare:read:)` en version async).
- API CloudKit `database.records(matching:)` (iOS 15+) et le format des prédicats.
- VisionKit `DataScannerViewController` (disponibilité, délégué).
- Noms de symboles AdMob selon la version du SDK.
- Sign in with Apple : flux `ASAuthorizationController` à brancher à l'onboarding si vous voulez un credential explicite (l'identité de sync repose déjà sur le compte iCloud).

## 7. Tests
`KcalScanTests/NutritionCalculatorTests.swift` couvre BMR/TDEE/cible/macros (logique pure, exécutable sans appareil).

## 8. Checklist App Store
- Politique de confidentialité + Conditions (URLs à ajouter dans Settings et App Store Connect).
- Nutrition **non médicale** (disclaimers présents dans l'UI).
- Disclaimer **IA photo** (présent dans `PhotoAnalysisView`).
- Données santé jamais utilisées pour la pub (règle Apple).
- Transparence publicitaire + ATT + RGPD/UMP pour l'UE.
- App **gratuite**, sans achat intégré ni abonnement.
