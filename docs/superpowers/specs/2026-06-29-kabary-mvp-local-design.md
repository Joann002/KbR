# Spec de conception — Kabary MVP local (APK simple)

> Date : 2026-06-29
> Statut : approuvé pour rédaction du plan d'implémentation
> Référence projet : [plan_conception_kabary_app.md](../../../plan_conception_kabary_app.md), [CLAUDE.md](../../../CLAUDE.md)

## 1. Objectif et périmètre

Premier livrable : un **APK Flutter simple, 100 % local, sans authentification ni notion d'utilisateur, sans Firebase**. Il sert de socle fonctionnel et démontre le cœur de valeur de Kabary : consulter le patrimoine oratoire malgache hors-ligne.

### Dans le périmètre
- **Accueil** : proverbe du jour + kabary récents + raccourcis.
- **Bibliothèque de Kabary** : liste par occasion, filtres (région / occasion / niveau), lecture du texte intégral (malgache + traduction française).
- **Ohabolana (proverbes)** : liste, recherche, fiche détaillée, classement thématique.
- **Favoris** : marquer kabary et ohabolana en favori, stockés localement dans Hive, sans compte.
- **Design system** : couleurs, typographies, thème clair/sombre.
- **Contenu** : jeu de données d'exemple embarqué dans les assets (quelques kabary + une dizaine d'ohabolana authentiques connus).

### Hors périmètre (reporté aux phases ultérieures)
Authentification / utilisateur, Firebase / Firestore / Storage, Algolia, audio / vidéo, carte / géolocalisation, module Compositeur (IA), Apprentissage, Enregistrements, Mpikabary, Événements, Communauté, monétisation Premium, multilingue complet (l'interface démarre en français ; le contenu reste mg + fr).

## 2. Décisions d'architecture

**Approche retenue : architecture en couches légère, par feature** (option A du brainstorming).

- Structure `features/<x>/{data, presentation}` + un `core/` partagé.
- On conserve l'abstraction **Repository** (interface + implémentation locale lisant Hive), ce qui permettra de brancher un backend cloud plus tard **sans toucher à l'UI** — fidèle à l'esprit Clean Architecture du plan.
- On **omet la couche UseCase / Entities séparée** tant que la logique métier reste faible. Elle pourra être réintroduite feature par feature ultérieurement.
- State management : **Riverpod 2.0** (avec génération de code `riverpod_annotation`).
- Persistance : **Hive** uniquement.
- Navigation : **go_router** avec `ShellRoute` pour la bottom navigation.

## 3. Structure des dossiers

```
lib/
├── core/
│   ├── theme/          ← couleurs, typographies, ThemeData (clair/sombre)
│   ├── router/         ← go_router + ShellRoute (bottom nav)
│   ├── data/           ← seed_service (JSON assets → Hive au 1er lancement) + init Hive
│   └── widgets/        ← widgets partagés (carte, badge occasion, etc.)
├── features/
│   ├── accueil/
│   │   └── presentation/   ← page d'accueil + providers
│   ├── bibliotheque/
│   │   ├── data/           ← Kabary model, KabaryRepository (interface + impl Hive)
│   │   └── presentation/   ← liste, détail, filtres, providers
│   ├── ohabolana/
│   │   ├── data/           ← Ohabolana model, OhabolanaRepository (interface + impl Hive)
│   │   └── presentation/   ← liste, recherche, détail, providers
│   └── favoris/
│       ├── data/           ← FavorisRepository (interface + impl Hive)
│       └── presentation/   ← page favoris + providers
└── main.dart

assets/data/
├── kabary.json         ← 3 à 5 kabary d'exemple
└── ohabolana.json      ← 10 à 15 ohabolana authentiques
```

## 4. Modèle de données

### Kabary
| Champ | Type | Notes |
|---|---|---|
| id | String | uuid |
| titre | String | |
| occasion | String (enum) | Fanambadiana, Famadihana, Famorana, Fihaonana, Vodiondry, Fisaorana, Fangatahana |
| region | String | Imerina, Betsileo, Betsimisaraka… |
| dureeMinutes | int | durée approximative |
| niveau | String (enum) | Débutant, Intermédiaire, Expert |
| sections | List<KabarySection> | titre + contenu (mg) + traduction (fr) |
| ohabolanaIds | List<String> | proverbes liés |

### Ohabolana
| Champ | Type | Notes |
|---|---|---|
| id | String | uuid |
| texteMg | String | texte malgache |
| translitteration | String? | prononciation |
| traductionFr | String | traduction française |
| signification | String? | sens / explication |
| themes | List<String> | respect, famille, nature, sagesse, communauté… |
| usage | String? | contexte d'usage dans un kabary |

### Persistance Hive
- Box `kabary` (clé = id), box `ohabolana` (clé = id).
- Box `favoris` stockant les ids favoris (kabary + ohabolana), via préfixe de type ou deux listes distinctes.
- Box `meta` pour un flag `seeded` (déclenche le seed une seule fois).
- Modèles annotés `@HiveType` ou stockés en map JSON ; choix tranché au plan d'implémentation.

### Seed
Au 1er lancement, `core/data/seed_service` lit `assets/data/*.json`, désérialise et peuple les boxes Hive, puis positionne `meta.seeded = true`. Lectures ultérieures 100 % locales.

## 5. Navigation et écrans

Bottom navigation à **3 onglets + Favoris = 4 onglets** :

```
┌────────┬──────────────┬───────────┬─────────┐
│ 🏠     │ 📚           │ 🌿        │ ⭐      │
│ Accueil│ Bibliothèque │ Ohabolana │ Favoris │
└────────┴──────────────┴───────────┴─────────┘
```

Écrans :
- **Accueil** : proverbe du jour (ohabolana tiré par date), kabary récents (cartes), raccourcis vers les listes.
- **Bibliothèque** : liste filtrable (région / occasion / niveau) → **Détail kabary** (sections mg + fr, proverbes liés cliquables, bouton favori, partage texte).
- **Ohabolana** : liste + barre de recherche (texte mg/fr) + filtre thématique → **Détail ohabolana** (texte, translittération, traduction, signification, usage, favori).
- **Favoris** : kabary et ohabolana marqués, regroupés par type.

Routing : `go_router` avec `ShellRoute` portant la bottom nav ; routes détail empilées au-dessus.

## 6. Design system

| Rôle | Hex |
|---|---|
| Primaire (Rouge royal) | `#C0392B` |
| Secondaire (Vert forêt) | `#1E7E34` |
| Accent (Or Lamba) | `#D4AC0D` |
| Fond clair (Ivoire chaud) | `#FAF7F0` |
| Fond sombre (Brun nuit) | `#1C1208` |
| Texte (Brun profond) | `#2C1810` |

Typographies via `google_fonts` : **Playfair Display** (titres), **Noto Sans** (corps, support malgache complet), **Cormorant Garamond** (citations / proverbes). Thèmes clair et sombre fournis.

## 7. Dépendances

Sous-ensemble local du plan :
`flutter_riverpod`, `riverpod_annotation` (+ `build_runner`, `riverpod_generator` en dev), `hive`, `hive_flutter` (+ `hive_generator` en dev si modèles annotés), `go_router`, `google_fonts`, `json_annotation` (+ `json_serializable` en dev), `uuid`, `share_plus`, `flutter_svg`.

**Exclus du MVP** : Firebase (tous), Algolia, just_audio / audio_waveforms, video_player / chewie, flutter_map / geolocator, dio, pdf.

## 8. Tests (TDD)

- **Unitaires** : `SeedService` (peuple Hive depuis JSON, idempotent via flag), `KabaryRepository` / `OhabolanaRepository` (lecture, filtres, recherche), `FavorisRepository` (ajout/retrait/persistance).
- **Widgets** : écran Accueil (proverbe du jour rendu), liste Bibliothèque + application d'un filtre, recherche Ohabolana, bascule favori.
- Outils : `flutter_test`, overrides de providers Riverpod, Hive en mémoire/temp pour l'isolation des tests.

## 9. Contraintes (héritées du plan)

- Optimisation faible connexion : non bloquant ici puisque tout est local et embarqué.
- Cible Android 6.0+ ; viser un APK léger.
- Support Unicode malgache complet (assuré par Noto Sans).

## 10. Évolutions prévues (post-MVP)

Réintroduction progressive, sans casser l'UI grâce aux interfaces Repository : backend cloud (Firebase), authentification / profil, audio synchronisé, Compositeur IA (API Anthropic), recherche full-text (Algolia), modules Apprentissage / Mpikabary / Événements / Communauté, multilingue mg/fr/en complet.
