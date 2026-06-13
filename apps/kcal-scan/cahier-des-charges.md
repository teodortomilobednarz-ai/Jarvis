# kcal-scan — Cahier des charges

App iOS de comptage de calories assistée par IA. Objectif : publication **App Store**.

> Statut : spécification v1. Le code se développe sur **Mac + Xcode** (non compilable dans l'environnement Linux actuel). Ce dossier est hébergé temporairement dans Jarvis ; à transférer dans le dépôt dédié `kcal-scan`.

## 1. Vision
Aider l'utilisateur à suivre ses calories et macros au quotidien avec le minimum de friction :
- Saisie ultra-rapide via **scan de code-barres** et **photo d'assiette** (IA).
- Besoin calorique **personnalisé et réel** (BMR/TDEE), ajusté chaque jour par les **pas Apple Health**.
- Cible adaptée à l'**objectif** (sèche, prise de masse, maintien, perte de poids).

## 2. Cible
Particuliers FR/EU souhaitant suivre leur nutrition (sport, perte de poids, prise de masse). iPhone, iOS 17+.

## 3. Périmètre v1 (validé : tout inclus, photo IA comprise)
1. Compte + authentification.
2. Profil corporel et objectif.
3. Calcul automatique du besoin calorique et des macros.
4. Connexion Apple Health (pas + énergie active).
5. Journal alimentaire quotidien.
6. Ajout d'aliment par **scan code-barres**.
7. Ajout d'aliment par **photo d'assiette** (IA).
8. Saisie manuelle / recherche d'aliment.
9. Tableau de bord (restant du jour, répartition macros, historique).

## 4. Parcours utilisateur
1. **Onboarding** → Sign in with Apple → saisie profil (sexe, âge, taille, poids, niveau d'activité, objectif).
2. L'app calcule **BMR → TDEE → cible** et propose les macros.
3. Demande l'autorisation **HealthKit** (pas / énergie active).
4. Écran d'accueil : « calories restantes aujourd'hui » + anneaux macros.
5. Bouton **+** : scan code-barres · photo d'assiette · recherche manuelle.
6. Chaque ajout met à jour le restant ; les pas du jour augmentent la dépense → le restant.

## 5. Calculs (formules réelles, à implémenter à l'identique)

### 5.1 BMR — Mifflin-St Jeor
Poids en kg, taille en cm, âge en années.
- **Homme** : `BMR = 10·poids + 6.25·taille − 5·âge + 5`
- **Femme** : `BMR = 10·poids + 6.25·taille − 5·âge − 161`

### 5.2 TDEE (dépense totale)
Deux modes :
- **Avec HealthKit (recommandé, plus précis)** : `TDEE = BMR · 1.2 + energie_active_HealthKit_du_jour`
  (1.2 = métabolisme de base au repos ; on ajoute la dépense active réelle `activeEnergyBurned` pour éviter le double comptage).
- **Sans HealthKit (repli)** : `TDEE = BMR · facteur_activité` (PAL) :
  | Niveau | Facteur |
  |--------|---------|
  | Sédentaire | 1.2 |
  | Léger (1-3 j/sem) | 1.375 |
  | Modéré (3-5 j/sem) | 1.55 |
  | Intense (6-7 j/sem) | 1.725 |
  | Très intense / athlète | 1.9 |

> Estimation pas→kcal en secours si `activeEnergyBurned` indisponible : `kcal ≈ pas · 0.04` (approx. ; préférer toujours la valeur HealthKit réelle).

### 5.3 Cible calorique selon l'objectif
Appliquée sur le TDEE, avec **plancher de sécurité** (ne jamais passer sous le BMR ; min absolu 1500 H / 1200 F kcal) :
| Objectif | Ajustement |
|----------|------------|
| Perte de poids (modérée) | −15 à −20 % (≈ −500 kcal/j) |
| Sèche | −20 à −25 % |
| Maintien | TDEE |
| Prise de masse (PDM) | +10 à +15 % (≈ +250 à +400 kcal/j) |

### 5.4 Macros (par kg de poids)
- **Protéines** : 1.6–2.2 g/kg (haut de fourchette en sèche).
- **Lipides** : 0.8–1.0 g/kg (plancher ~0.6).
- **Glucides** : reste des calories. (1 g P = 4 kcal, 1 g G = 4 kcal, 1 g L = 9 kcal.)

## 6. Sources de données nutritionnelles
- **Code-barres** : Open Food Facts — API publique gratuite : `https://world.openfoodfacts.org/api/v2/product/{barcode}.json` (champs `nutriments`: energy-kcal_100g, proteins, carbohydrates, fat). Base mondiale, données par 100 g → multiplier par la portion.
- **Photo d'assiette (IA)** : envoi de l'image à un **modèle multimodal (vision)** via backend → retour structuré `{ aliments[], portion_estimée_g, kcal, protéines, glucides, lipides, confiance }`. Le choix du fournisseur (coût/précision) est à **benchmarker** avant fixation. Toujours laisser l'utilisateur corriger les quantités estimées.
- **Recherche manuelle** : Open Food Facts (search) ou base CIQUAL (ANSES) pour aliments bruts FR.

## 7. Architecture technique (cible)
- **Langage/UI** : Swift 5.9+, **SwiftUI**, iOS 17+.
- **Santé** : **HealthKit** — lecture `HKQuantityTypeIdentifier.stepCount` et `activeEnergyBurned` (et option poids `bodyMass`).
- **Scan code-barres** : VisionKit `DataScannerViewController` (ou AVFoundation `AVCaptureMetadataOutput`).
- **Caméra photo** : `PHPickerViewController` / `UIImagePickerController` + upload backend.
- **Persistance locale** : **SwiftData** (iOS 17) ou Core Data.
- **Auth** : **Sign in with Apple** (recommandé, exigé par l'App Store si d'autres connexions sociales existent).
- **Backend / sync** : Firebase (Auth + Firestore) ou Supabase ; sinon CloudKit pour rester 100 % Apple. Le backend héberge aussi l'appel au modèle vision (la clé API ne doit jamais être dans l'app).

## 8. Modèle de données (simplifié)
- **User** : id, email, dateCréation.
- **Profile** : sexe, âge, taille_cm, poids_kg, niveauActivité, objectif, cibleKcal, cibleP/G/L.
- **DayLog** : date, kcalConsommées, pas, énergieActive, restant.
- **FoodEntry** : id, dayLogId, nom, source (barcode/photo/manuel), portion_g, kcal, prot, gluc, lip, horodatage.

## 9. Contraintes App Store / conformité
- **ATT / vie privée** : déclarer l'usage des données santé (HealthKit) ; ne pas utiliser les données santé à des fins publicitaires (règle Apple stricte).
- **Privacy Manifest** + descriptions d'usage (`NSHealthShareUsageDescription`, `NSCameraUsageDescription`).
- **RGPD** : consentement, export/suppression des données, hébergement EU si possible.
- **Sign in with Apple** obligatoire si connexions tierces présentes.
- Avis : éviter les promesses de santé médicales ; positionner comme outil de suivi, pas dispositif médical.

## 10. Roadmap
- **MVP technique** : onboarding + calculs + journal manuel + HealthKit + scan code-barres.
- **v1 complète** : + photo d'assiette IA + tableau de bord + historique.
- **v2** : widgets, Apple Watch, rappels, partage, abonnement (monétisation).

## 11. Questions ouvertes (à trancher avant dev)
- Fournisseur du modèle vision (coût par photo, précision sur plats FR).
- Backend : Firebase vs Supabase vs CloudKit.
- Monétisation : gratuit + premium (abonnement) ? quelles features payantes ?
- Nom commercial / identité de marque de l'app.
