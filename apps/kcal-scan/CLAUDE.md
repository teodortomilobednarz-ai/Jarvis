# kcal-scan — Instructions projet (app iOS)

App iOS native de comptage de calories par IA. Destination : **App Store**.
Voir `cahier-des-charges.md` pour les specs complètes.

> Ce dossier vit temporairement dans Jarvis. À déplacer vers le dépôt dédié `kcal-scan` (développement Xcode sur Mac — non compilable sous Linux).

## Stack
- Swift 5.9+, **SwiftUI**, iOS 17+.
- **HealthKit** (pas, énergie active), **VisionKit** (scan code-barres), caméra (photo IA).
- Persistance : **SwiftData** (ou Core Data). Auth : **Sign in with Apple**.
- Backend (Firebase/Supabase/CloudKit) : héberge la sync + l'appel au modèle vision. **Aucune clé API dans l'app.**

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
