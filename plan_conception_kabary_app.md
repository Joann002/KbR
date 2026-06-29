# 📱 Plan de Conception — Application Flutter **"Kabary"**
> Patrimoine oratoire malgache numérisé

---

## 1. VISION & OBJECTIFS

### Vision
Créer une application mobile de référence pour préserver, enseigner et valoriser l'art du kabary malgache, accessible à tous — débutants, mpikabary confirmés et chercheurs culturels.

### Objectifs principaux
- **Préserver** le patrimoine oratoire malgache
- **Enseigner** les techniques du kabary aux nouvelles générations
- **Connecter** la communauté des mpikabary
- **Référencer** les proverbes (ohabolana) et les formules rituelles

### Public cible
| Segment | Description |
|---|---|
| Apprenants | Jeunes Malgaches souhaitant apprendre le kabary |
| Mpikabary | Orateurs professionnels cherchant des ressources |
| Familles | Personnes préparant un mariage, famadihana, famorana |
| Diaspora | Malgaches à l'étranger voulant garder le lien culturel |
| Chercheurs | Ethnologues, linguistes, étudiants |

---

## 2. ARCHITECTURE TECHNIQUE

### Stack technologique
```
Frontend       : Flutter 3.x (Dart)
Backend        : Firebase (Auth, Firestore, Storage, FCM)
State Mgmt     : Riverpod 2.0
Base locale    : Hive (mode hors-ligne)
Audio          : just_audio + audio_waveforms
Vidéo          : video_player + chewie
Recherche      : Algolia (recherche full-text)
Analytics      : Firebase Analytics + Crashlytics
IA             : API Anthropic (aide à la composition)
```

### Architecture Clean Architecture
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/          ← Repositories, DataSources
│   │   ├── domain/        ← Entities, UseCases
│   │   └── presentation/  ← Pages, Widgets, Providers
│   ├── bibliotheque/
│   ├── ohabolana/
│   ├── apprentissage/
│   ├── enregistrements/
│   ├── mpikabary/
│   ├── compositeur/
│   ├── evenements/
│   └── communaute/
└── main.dart
```

### Flux de données
```
UI (Flutter Widget)
     ↓↑
Provider (Riverpod)
     ↓↑
UseCase (Domain)
     ↓↑
Repository (Interface)
     ↓↑
   ┌─────────────┐
   │ FireStore   │  ← en ligne
   │ Hive (local)│  ← hors-ligne
   └─────────────┘
```

---

## 3. MODULES FONCTIONNELS

### MODULE 1 — Authentification
- Connexion via Google / Email / Téléphone (numéros malgaches prioritaires)
- Profil utilisateur : nom, région, niveau (débutant / intermédiaire / mpikabary)
- Mode invité avec accès limité en lecture seule

---

### MODULE 2 — Bibliothèque de Kabary 📚
**Description** : Collection structurée de textes de kabary classés par occasion.

#### Catégories d'occasions
| Occasion | Description |
|---|---|
| Fanambadiana | Mariage |
| Famadihana | Retournement des morts |
| Famorana | Circoncision |
| Fihaonana | Réunion communautaire |
| Vodiondry | Demande en mariage |
| Fisaorana | Remerciements |
| Fangatahana | Demande officielle |

#### Fonctionnalités
- Filtres : région (Merina, Betsileo, Betsimisaraka…), occasion, durée, niveau
- Lecture en texte intégral (malgache + traduction en français)
- Lecture audio synchronisée avec le texte (karaoké-style)
- Favoris et listes personnalisées
- Mode hors-ligne (téléchargement de textes)
- Partage via WhatsApp/Facebook

#### Structure d'un kabary (affichage)
```
┌─────────────────────────────────┐
│  🟥  Kabary - Fanambadiana      │
│  ─────────────────────────────  │
│  Occasion : Mariage             │
│  Région   : Imerina             │
│  Durée    : ~15 min             │
│  Niveau   : Intermédiaire       │
│  ─────────────────────────────  │
│  SALUTATION (Fiarahana)         │
│  FORMULE D'OUVERTURE            │
│  CORPS DU DISCOURS              │
│  PROVERBES UTILISÉS  [voir 5]   │
│  FORMULE DE CLÔTURE             │
│  ─────────────────────────────  │
│  [▶ Écouter]  [⬇ Télécharger]  │
└─────────────────────────────────┘
```

---

### MODULE 3 — Ohabolana (Proverbes) 🌿
**Description** : Dictionnaire interactif des proverbes malgaches utilisés dans le kabary.

#### Fonctionnalités
- Recherche par mot-clé en malgache ou français
- Chaque proverbe : texte malgache + translittération + traduction + signification + exemples d'usage dans un kabary
- Proverbe du jour (widget home)
- Classement thématique : respect, famille, nature, sagesse, communauté…
- Écouter la prononciation
- Ajouter ses propres notes

#### Exemple de fiche Ohabolana
```
┌─────────────────────────────────────┐
│  "Ny fihavanana no tsy mba azo      │
│   vidina vola"                      │
│                                     │
│  Prononciation : [audio 🔊]         │
│  Traduction : La solidarité ne      │
│  s'achète pas avec de l'argent      │
│  Thème : Fihavanana, Communauté     │
│  Usage : Ouverture d'un kabary      │
│          de mariage                 │
│  Kabary associés : [voir 3]         │
└─────────────────────────────────────┘
```

---

### MODULE 4 — Apprentissage 🎓
**Description** : Parcours structuré pour apprendre l'art du kabary.

#### Niveaux
```
DÉBUTANT          INTERMÉDIAIRE        EXPERT
─────────         ─────────────        ──────
Introduction      Structure du         Styles régionaux
au kabary         kabary               Improvisation
                                       Maîtrise des
Ohabolana         Les formules         figures de style
de base           rituelles
                                       Simulations
Écoute            Exercices            d'événements réels
active            d'articulation
```

#### Fonctionnalités
- Leçons vidéo avec mpikabary reconnus
- Exercices interactifs : compléter un kabary, choisir le bon proverbe, remettre dans l'ordre
- Quiz culturels
- Suivi de progression avec badges et certificats
- Enregistre-toi et compare avec un modèle (analyse audio basique)
- Défis hebdomadaires

---

### MODULE 5 — Enregistrements 🎙️
**Description** : Médiathèque audio et vidéo de kabary authentiques.

#### Fonctionnalités
- Lecteur audio avec visualisation de la forme d'onde
- Vidéos de kabary lors d'événements réels
- Transcription synchronisée (sous-titres)
- Vitesse de lecture : 0.5x / 0.75x / 1x / 1.5x
- Annotations personnelles sur la timeline
- Contributions de la communauté (upload après validation)
- Qualité : filtrée par un comité éditorial

---

### MODULE 6 — Répertoire des Mpikabary 👤
**Description** : Annuaire des orateurs reconnus.

#### Fiche Mpikabary
```
┌──────────────────────────────┐
│  [Photo]  Jean Razafy        │
│           Antananarivo       │
│  ⭐⭐⭐⭐⭐  Maître Kabary    │
│  ─────────────────────────── │
│  Spécialités :               │
│  ✓ Fanambadiana              │
│  ✓ Famadihana               │
│  ✓ Fihaonana                │
│  ─────────────────────────── │
│  Région d'intervention :     │
│  Imerina, Vakinankaratra     │
│  ─────────────────────────── │
│  [📞 Contacter] [▶ Écouter] │
└──────────────────────────────┘
```

#### Fonctionnalités
- Géolocalisation des mpikabary proches
- Avis et évaluations de la communauté
- Portfolio audio/vidéo
- Prise de contact directe (messagerie in-app)
- Mise en relation pour événements

---

### MODULE 7 — Compositeur de Kabary ✍️
**Description** : Outil d'aide à la rédaction d'un kabary personnalisé.

#### Fonctionnalités
- Assistant guidé étape par étape :
  1. Choix de l'occasion
  2. Informations sur les protagonistes
  3. Ton souhaité (solennel / festif / sobre)
  4. Région/dialecte
- Suggestions automatiques d'ohabolana appropriées
- Génération d'un plan structuré (avec sections pré-remplies)
- Aide IA (Claude) pour affiner le discours
- Export PDF / partage / impression
- Sauvegardes dans "Mes Kabary"

#### Interface du compositeur
```
┌──────────────────────────────────────┐
│  COMPOSITEUR DE KABARY               │
│  ─────────────────────────────────── │
│  Occasion : [Mariage ▼]              │
│  Région   : [Imerina ▼]              │
│  Durée    : [Court ●] Moyen  Long    │
│  ─────────────────────────────────── │
│  STRUCTURE GÉNÉRÉE :                 │
│  1. Fiarahana (Salutation)     ✏️   │
│  2. Fampidirana (Introduction) ✏️   │
│  3. Vohitra (Corps)            ✏️   │
│  4. Fanononana (Proverbes)     +     │
│  5. Farany (Conclusion)        ✏️   │
│  ─────────────────────────────────── │
│  [💡 Suggestion IA] [📤 Exporter]   │
└──────────────────────────────────────┘
```

---

### MODULE 8 — Événements & Calendrier 📅
**Description** : Agenda des événements liés au kabary.

#### Fonctionnalités
- Concours de kabary (locaux et nationaux)
- Ateliers et formations
- Événements culturels
- Géolocalisation des événements proches
- Rappels et notifications
- Inscription en ligne aux ateliers

---

### MODULE 9 — Communauté 🤝
**Description** : Espace d'échange entre passionnés et praticiens.

#### Fonctionnalités
- Forum organisé par thèmes
- Partage d'extraits audio/vidéo de kabary
- Fil d'actualités culturelles
- Groupes régionaux
- Système de réputation (contributeur actif, expert…)
- Modération communautaire

---

### MODULE 10 — Profil & Paramètres ⚙️
- Historique de lecture et d'écoute
- Mes kabary favoris
- Mes compositions sauvegardées
- Paramètres de langue (malgache / français / anglais)
- Mode sombre / clair
- Notifications personnalisées
- Abonnement Premium (si monétisation)

---

## 4. DESIGN UI/UX

### Identité visuelle
Inspirée du lamba malgache et du drapeau national.

#### Palette de couleurs
| Rôle | Couleur | Hex |
|---|---|---|
| Primaire | Rouge royal | `#C0392B` |
| Secondaire | Vert forêt | `#1E7E34` |
| Accent | Or Lamba | `#D4AC0D` |
| Fond clair | Ivoire chaud | `#FAF7F0` |
| Fond sombre | Brun nuit | `#1C1208` |
| Texte | Brun profond | `#2C1810` |

#### Typographie
- **Titres** : Playfair Display (majestueux, traditionnel)
- **Corps** : Noto Sans (lisibilité, support malgache complet)
- **Accent** : Cormorant Garamond (pour les citations et proverbes)

#### Navigation principale (Bottom Navigation Bar)
```
┌────┬────┬────┬────┬────┐
│ 🏠 │ 📚 │ ✍️ │ 🎙 │ 👤 │
│Accueil│Biblio│Composer│Média│Profil│
└────┴────┴────┴────┴────┘
```

#### Wireframe — Écran d'accueil
```
┌────────────────────────────────┐
│  🔴 KABARY        🔔  [👤]    │
│ ─────────────────────────────  │
│  Ohabolana du jour             │
│  ┌────────────────────────┐   │
│  │ "Ny teny no mpanasaraka│   │
│  │  ny fon'ny olona"      │   │
│  │                    🔊  │   │
│  └────────────────────────┘   │
│                                │
│  Kabary récents               │
│  ┌──────┐  ┌──────┐           │
│  │Fana- │  │Famad-│           │
│  │mbad. │  │ihana │           │
│  └──────┘  └──────┘           │
│                                │
│  Mpikabary près de vous        │
│  [Carte avec marqueurs]        │
│                                │
│  Prochains événements          │
│  📅 Concours - 15 juillet     │
└────────────────────────────────┘
```

---

## 5. SCHÉMA DE BASE DE DONNÉES (Firestore)

```
/users/{userId}
   - name, email, region, level, avatar
   - favoriteKabary[], favoriteOhabolana[]
   - myCompositions[]

/kabary/{kabaryId}
   - title, occasion, region, duration, level
   - content (sections[])
   - audioUrl, videoUrl
   - ohabolanaIds[]
   - authorId, validated (bool)
   - createdAt, views, likes

/ohabolana/{ohabolanaId}
   - text_mg, text_fr, pronunciation
   - theme[], audioUrl
   - relatedKabaryIds[]
   - createdAt, views

/mpikabary/{mpikabaryId}
   - name, bio, region, photo
   - specialties[], contact
   - kabaryIds[], ratings[]
   - verified (bool)

/events/{eventId}
   - title, description, location
   - date, organizer
   - registrationUrl, imageUrl

/community/posts/{postId}
   - authorId, content, mediaUrl
   - likes, comments[]
   - tags[], createdAt
```

---

## 6. MONÉTISATION

| Modèle | Description |
|---|---|
| **Freemium** | Accès gratuit aux contenus de base |
| **Premium** | 2 000 Ar/mois — accès illimité, hors-ligne complet, IA Compositeur |
| **Mpikabary Pro** | Profil vérifié + mise en avant dans l'annuaire |
| **Partenariats** | ONGs culturelles, Alliance Française, Ministère de la Culture |
| **Ateliers** | Commission sur les inscriptions aux formations |

---

## 7. PLAN DE DÉVELOPPEMENT

### Phase 1 — MVP (Mois 1–3)
- [ ] Setup Flutter + Firebase + architecture Clean
- [ ] Authentification (Google + Email)
- [ ] Module Bibliothèque (lecture texte + filtres)
- [ ] Module Ohabolana (base de données + recherche)
- [ ] Design system (thème, composants de base)
- [ ] Mode hors-ligne basique (Hive)

### Phase 2 — Contenu & Communauté (Mois 4–5)
- [ ] Module Enregistrements (audio + vidéo)
- [ ] Répertoire des Mpikabary
- [ ] Module Apprentissage (leçons + quiz)
- [ ] Module Événements
- [ ] Module Communauté (forum + partage)
- [ ] Notifications push (FCM)

### Phase 3 — IA & Finalisation (Mois 6–7)
- [ ] Module Compositeur avec aide IA (API Anthropic)
- [ ] Géolocalisation (mpikabary proches, événements)
- [ ] Système de gamification (badges, progression)
- [ ] Monétisation Premium (in-app purchase)
- [ ] Analytics & Crashlytics
- [ ] Tests unitaires, d'intégration, E2E
- [ ] Publication Play Store + App Store

---

## 8. DÉPENDANCES FLUTTER (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
  firebase_analytics: ^11.0.0

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Local Storage
  hive_flutter: ^1.1.0

  # Audio & Vidéo
  just_audio: ^0.9.36
  audio_waveforms: ^1.0.5
  video_player: ^2.8.0
  chewie: ^1.7.0

  # UI
  google_fonts: ^6.2.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^3.1.0
  flutter_svg: ^2.0.10

  # Navigation
  go_router: ^14.0.0

  # Carte
  flutter_map: ^7.0.0
  geolocator: ^12.0.0

  # Utilitaires
  intl: ^0.19.0
  share_plus: ^9.0.0
  url_launcher: ^6.2.5
  dio: ^5.4.0
  json_annotation: ^4.9.0
  uuid: ^4.3.3
  pdf: ^3.11.0
```

---

## 9. CONSIDÉRATIONS SPÉCIALES

### Accessibilité linguistique
- Interface disponible en **malgache officiel**, **français** et **anglais**
- Support complet des caractères malgaches (Unicode)
- Synthèse vocale (TTS) pour les utilisateurs peu lettrés

### Contraintes techniques malgaches
- Optimisation pour faible connexion (lazy loading, compression)
- Taille APK minimale (< 30 MB pour le téléchargement initial)
- Compatibilité Android 6.0+ (parc dominant à Madagascar)
- Mode hors-ligne complet pour le contenu téléchargé

### Validation culturelle
- Comité éditorial composé de mpikabary reconnus
- Processus de validation avant publication de tout contenu
- Respect des variantes régionales (Merina, Betsileo, côtiers…)
- Consultation des Académie Malagasy et institutions culturelles

---

## 10. INDICATEURS DE SUCCÈS (KPIs)

| Indicateur | Objectif (6 mois) |
|---|---|
| Téléchargements | 10 000 |
| Utilisateurs actifs mensuels | 3 000 |
| Kabary indexés | 200+ |
| Ohabolana catalogués | 1 000+ |
| Mpikabary enregistrés | 50+ |
| Note Play Store | ≥ 4.5 ⭐ |

---

*Document réalisé pour le projet "Kabary — Patrimoine Oratoire Malgache Numérisé"*
*Version 1.0 — Juin 2026*
