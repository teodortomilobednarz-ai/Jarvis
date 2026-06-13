# kcal-scan — Instructions projet (app iOS)

App iOS native de comptage de calories par IA. Destination : **App Store**.
Voir `docs/cahier-des-charges.md` pour les specs complètes et `docs/BUILD-SETUP.md` pour la config Xcode.

> Ce dossier vit temporairement dans Jarvis. À déplacer vers le dépôt dédié `kcal-scan` (développement Xcode sur Mac — non compilable sous Linux).

## Organisation du dossier
- `app/` — **code de l'application** (`KcalScan/`, `KcalScanTests/`).
- `docs/` — documentation Markdown (cahier des charges, build).
- `mockup/` — maquette visuelle HTML (`preview.html`).
- `CLAUDE.md` — ce fichier (instructions projet).

## Stack (choix V1 validés)
- Swift 5.9+, **SwiftUI**, iOS 17+, ViewModels `@Observable`.
- **HealthKit** (pas, énergie active, poids/taille/âge si dispo), **VisionKit** (scan code-barres), **PhotosUI** (photo IA).
- Sync : **CloudKit** (private DB), mapping **CKRecord manuel** + cache local offline (`LocalStore`).
- Auth/identité : compte **iCloud** (CloudKit) + **Sign in with Apple**.
- Vision IA : **OpenAI Vision** via **proxy backend** (clé jamais dans l'app). Mock tant que `Config.visionEndpoint == nil`.
- Monétisation : **100 % gratuit, financé par la pub** (AdMob via `AdsService`). Aucun abonnement, IAP ni paywall — ne jamais créer de `Subscription*`.

## Architecture (MVVM + Services + Repositories)
`View → ViewModel → Repository → Service(s)`. Voir `docs/BUILD-SETUP.md` pour la config Xcode.
```
app/KcalScan/
  App/         KcalScanApp, AppEnvironment (DI), RootView (TabView + bouton +)
  Models/      UserProfile, NutritionGoal, MacroNutrients, FoodItem, FoodEntry,
               MealType, DailyNutritionSummary, ActivityLevel, NutritionObjective, Ads/*
  Services/    Nutrition/NutritionCalculator, HealthKit, Network/OpenFoodFacts,
               Vision (mock + remote), CloudKit (+ CKRecordMapping), Ads (protocole + AdMob + Noop)
  Repositories/ User, Food, Nutrition
  Features/    Dashboard, Journal, Scanner(+Barcode/Manual), PhotoAnalysis,
               Progress, Settings, Onboarding, Consent  (chacun View + ViewModel)
  UI/Components/ AdBannerView, MacroRingView, CalorieRemainingView
  Support/     Config (TODO clés/endpoints), LocalStore
  Resources/   Info-additions.plist, KcalScan.entitlements
app/KcalScanTests/ NutritionCalculatorTests
```

## Règles publicité (AdsService)
- Bannières **uniquement** Dashboard / Journal / Progress.
- Interstitiel **après action terminée non critique** (ajout d'entrée), avec **cap de fréquence**.
- **Jamais** de pub pendant scan ou analyse photo.
- Consentement **ATT + RGPD/UMP** avant toute pub personnalisée.
- Abstraction `AdsService` : changer de régie sans toucher l'UI.

## Règles de calcul (ne pas inventer — voir cahier des charges §5)
- BMR : **Mifflin-St Jeor** (formule H/F exacte).
- TDEE : `BMR·1.2 + énergie active HealthKit` (mode précis) ou `BMR · facteur PAL` (repli).
- Cible selon objectif (sèche/PDM/maintien/perte) avec **plancher de sécurité**.
- Macros en g/kg. Toujours laisser l'utilisateur corriger les estimations IA.

## Données nutritionnelles
- Code-barres → **Open Food Facts** `https://world.openfoodfacts.org/api/v2/product/{barcode}.json`.
- Photo → modèle multimodal via backend, retour **structuré** (aliments, portion, kcal, macros, confiance).

## Conventions de dev
- Architecture claire (MVVM ou équivalent SwiftUI), vues testables.
- Données santé : usage strictement fonctionnel, jamais publicitaire (règle Apple).
- Déclarer les `*UsageDescription` (santé, caméra) + Privacy Manifest.
- Ne jamais committer de secret. Variables sensibles côté backend.

## Conventions générales (héritées de Jarvis)
- Répondre en français, détaillé mais bref.
- Demander permission avant de créer/modifier des fichiers et avant toute action sensible.
- Lire avant d'écrire ; ne jamais deviner API, versions, packages : vérifier.
