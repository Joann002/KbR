# CLAUDE.md — Kabary

> Application mobile Flutter dédiée à la préservation, l'enseignement et la valorisation de l'art oratoire malgache (**kabary**).
> Référence complète : [plan_conception_kabary_app.md](plan_conception_kabary_app.md)

## Vision

Application de référence pour préserver le patrimoine oratoire malgache, enseigner le kabary, connecter la communauté des mpikabary, et référencer les proverbes (ohabolana) et formules rituelles.

Public cible : apprenants, mpikabary, familles (mariage/famadihana/famorana), diaspora, chercheurs.

## Stack technique

| Domaine | Choix |
|---|---|
| Frontend | Flutter 3.x (Dart) |
| Backend | Firebase (Auth, Firestore, Storage, FCM, Analytics, Crashlytics) |
| State management | Riverpod 2.0 (`flutter_riverpod`, `riverpod_annotation`) |
| Base locale / hors-ligne | Hive (`hive_flutter`) |
| Audio | `just_audio` + `audio_waveforms` |
| Vidéo | `video_player` + `chewie` |
| Recherche full-text | Algolia |
| Navigation | `go_router` |
| Carte / géoloc | `flutter_map` + `geolocator` |
| IA | API Anthropic (aide à la composition du kabary) |

## Architecture

**Clean Architecture** organisée par feature. Chaque feature contient trois couches :

```
lib/
├── core/                  ← constants, errors, theme, utils
├── features/
│   └── <feature>/
│       ├── data/          ← Repositories (impl), DataSources, Models
│       ├── domain/        ← Entities, UseCases, Repository interfaces
│       └── presentation/  ← Pages, Widgets, Providers (Riverpod)
└── main.dart
```

Flux de données : `UI → Provider (Riverpod) → UseCase → Repository (interface) → Firestore (en ligne) / Hive (hors-ligne)`.

Features : `auth`, `bibliotheque`, `ohabolana`, `apprentissage`, `enregistrements`, `mpikabary`, `compositeur`, `evenements`, `communaute`.

## Modules fonctionnels

1. **Authentification** — Google / Email / Téléphone (numéros malgaches prioritaires), mode invité lecture seule.
2. **Bibliothèque** — Textes de kabary classés par occasion (Fanambadiana, Famadihana, Famorana…), filtres région/occasion/durée/niveau, lecture audio synchronisée, favoris, hors-ligne, partage.
3. **Ohabolana (proverbes)** — Dictionnaire interactif : texte mg + translittération + traduction + signification + usage, proverbe du jour, classement thématique, prononciation audio.
4. **Apprentissage** — Parcours Débutant / Intermédiaire / Expert, leçons vidéo, exercices interactifs, quiz, progression avec badges.
5. **Enregistrements** — Médiathèque audio/vidéo, waveform, transcription synchronisée, vitesses de lecture, contributions validées par comité.
6. **Répertoire Mpikabary** — Annuaire géolocalisé, fiches, avis, portfolio, messagerie in-app.
7. **Compositeur** — Assistant guidé + aide IA (Claude) pour rédiger un kabary, suggestions d'ohabolana, export PDF.
8. **Événements & Calendrier** — Concours, ateliers, géoloc, rappels, inscriptions.
9. **Communauté** — Forum, partage de médias, groupes régionaux, réputation, modération.
10. **Profil & Paramètres** — Historique, favoris, langue (mg/fr/en), thème clair/sombre, notifications, Premium.

## Design system

Identité inspirée du lamba malgache et du drapeau national.

| Rôle | Hex |
|---|---|
| Primaire (Rouge royal) | `#C0392B` |
| Secondaire (Vert forêt) | `#1E7E34` |
| Accent (Or Lamba) | `#D4AC0D` |
| Fond clair (Ivoire chaud) | `#FAF7F0` |
| Fond sombre (Brun nuit) | `#1C1208` |
| Texte (Brun profond) | `#2C1810` |

Typographie : **Playfair Display** (titres), **Noto Sans** (corps, support malgache complet), **Cormorant Garamond** (citations/proverbes). Via `google_fonts`.

Navigation : Bottom Navigation Bar — Accueil · Bibliothèque · Composer · Média · Profil.

## Modèle de données (Firestore)

Collections : `/users`, `/kabary`, `/ohabolana`, `/mpikabary`, `/events`, `/community/posts`. Voir le plan §5 pour les champs détaillés.

## Plan de développement

- **Phase 1 — MVP (mois 1–3)** : setup Flutter + Firebase + Clean Architecture, Auth (Google + Email), Bibliothèque, Ohabolana, design system, hors-ligne Hive.
- **Phase 2 — Contenu & communauté (mois 4–5)** : Enregistrements, Mpikabary, Apprentissage, Événements, Communauté, FCM.
- **Phase 3 — IA & finalisation (mois 6–7)** : Compositeur IA (API Anthropic), géoloc, gamification, Premium, analytics, tests, publication stores.

## Contraintes spéciales

- **Linguistique** : interface mg / fr / en, support Unicode malgache complet, TTS envisagé.
- **Technique Madagascar** : optimisation faible connexion (lazy loading, compression), APK < 30 MB, Android 6.0+, hors-ligne complet pour contenu téléchargé.
- **Culturel** : comité éditorial de mpikabary, validation avant publication, respect des variantes régionales (Merina, Betsileo, côtiers…).

## Conventions de travail

- **Commits : NE JAMAIS ajouter de ligne `Co-Authored-By` ni de mention de co-auteur.** Messages de commit propres, sans signature d'agent.
- Architecture par feature en trois couches (data / domain / presentation) — respecter cette séparation.
- Privilégier le mode hors-ligne et l'optimisation réseau dans chaque choix d'implémentation.
