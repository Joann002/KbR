# Kabary MVP Local — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construire un APK Flutter simple, 100 % local (sans Firebase, sans auth), permettant de consulter des kabary et des ohabolana avec accueil, recherche, filtres et favoris locaux.

**Architecture:** Architecture en couches légère par feature (`features/<x>/{data,presentation}` + `core/`). Les modèles sont sérialisés manuellement en JSON et stockés dans Hive. Les repositories abstraient l'accès aux données ; les providers Riverpod manuels exposent repositories et état. Pas de génération de code (ni riverpod_generator ni json_serializable) pour ce premier livrable.

**Tech Stack:** Flutter 3.38 / Dart 3.10, flutter_riverpod, hive + hive_flutter, go_router, google_fonts, share_plus, uuid, flutter_test.

---

## Structure des fichiers

```
pubspec.yaml                              ← deps + déclaration des assets
assets/data/kabary.json                   ← données d'exemple kabary
assets/data/ohabolana.json                ← données d'exemple ohabolana
lib/main.dart                             ← bootstrap Hive + seed + ProviderScope
lib/core/theme/app_colors.dart            ← palette
lib/core/theme/app_theme.dart             ← ThemeData clair/sombre
lib/core/data/providers.dart              ← providers de Box Hive (override en main)
lib/core/data/seed_service.dart           ← seed JSON → Hive
lib/core/router/app_router.dart           ← go_router + ShellRoute (bottom nav)
lib/core/widgets/app_scaffold.dart        ← coquille bottom nav
lib/features/bibliotheque/data/kabary.dart            ← modèle Kabary + KabarySection
lib/features/bibliotheque/data/kabary_repository.dart ← repo + provider
lib/features/bibliotheque/presentation/bibliotheque_page.dart
lib/features/bibliotheque/presentation/kabary_detail_page.dart
lib/features/ohabolana/data/ohabolana.dart            ← modèle Ohabolana
lib/features/ohabolana/data/ohabolana_repository.dart ← repo + provider
lib/features/ohabolana/presentation/ohabolana_page.dart
lib/features/ohabolana/presentation/ohabolana_detail_page.dart
lib/features/favoris/data/favoris_repository.dart     ← repo + Notifier provider
lib/features/favoris/presentation/favoris_page.dart
lib/features/accueil/presentation/accueil_page.dart
test/seed_service_test.dart
test/kabary_repository_test.dart
test/ohabolana_repository_test.dart
test/favoris_repository_test.dart
test/accueil_page_test.dart
```

---

## Task 1: Scaffolder le projet Flutter

**Files:**
- Create: tout l'arbre Flutter à la racine `/home/happy/Documents/Joann/KbR`

- [ ] **Step 1: Créer le projet Flutter dans le dossier courant**

Le dossier `KbR` contient déjà `.git`, `README.md`, le plan et `docs/`. On crée le projet Flutter par-dessus (nom de projet `kabary` car `KbR` est invalide comme nom de package).

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter create --project-name kabary --platforms android,ios .
```
Expected: création de `lib/`, `android/`, `ios/`, `pubspec.yaml`, etc. Message « All done! ».

- [ ] **Step 2: Ajouter les dépendances**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter pub add flutter_riverpod hive hive_flutter go_router google_fonts 'share_plus:^11.0.0' uuid
```
Expected: les paquets sont ajoutés à `pubspec.yaml` et `flutter pub get` réussit. (On épingle `share_plus` à la branche 11.x pour utiliser l'API `SharePlus.instance.share(ShareParams(...))` employée en Task 10.)

- [ ] **Step 3: Vérifier que le projet compile/analyse**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter analyze
```
Expected: « No issues found! » (sur le projet généré par défaut).

- [ ] **Step 4: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add -A
git commit -m "chore: scaffold projet Flutter kabary + dépendances locales"
```

---

## Task 2: Palette et thème

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Créer la palette**

`lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

/// Palette Kabary, inspirée du lamba malgache et du drapeau national.
class AppColors {
  AppColors._();

  static const Color primaire = Color(0xFFC0392B); // Rouge royal
  static const Color secondaire = Color(0xFF1E7E34); // Vert forêt
  static const Color accent = Color(0xFFD4AC0D); // Or Lamba
  static const Color fondClair = Color(0xFFFAF7F0); // Ivoire chaud
  static const Color fondSombre = Color(0xFF1C1208); // Brun nuit
  static const Color texte = Color(0xFF2C1810); // Brun profond
}
```

- [ ] **Step 2: Créer le thème clair/sombre**

`lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Thèmes de l'application Kabary.
class AppTheme {
  AppTheme._();

  static ThemeData get clair {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.fondClair,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaire,
        primary: AppColors.primaire,
        secondary: AppColors.secondaire,
        tertiary: AppColors.accent,
        surface: AppColors.fondClair,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(textTheme: _textTheme(base.textTheme, AppColors.texte));
  }

  static ThemeData get sombre {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.fondSombre,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaire,
        primary: AppColors.primaire,
        secondary: AppColors.secondaire,
        tertiary: AppColors.accent,
        surface: AppColors.fondSombre,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme, const Color(0xFFFAF7F0)),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color couleurTexte) {
    final corps = GoogleFonts.notoSansTextTheme(base).apply(
      bodyColor: couleurTexte,
      displayColor: couleurTexte,
    );
    return corps.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(textStyle: corps.displayLarge),
      displayMedium: GoogleFonts.playfairDisplay(textStyle: corps.displayMedium),
      displaySmall: GoogleFonts.playfairDisplay(textStyle: corps.displaySmall),
      headlineLarge: GoogleFonts.playfairDisplay(textStyle: corps.headlineLarge),
      headlineMedium: GoogleFonts.playfairDisplay(textStyle: corps.headlineMedium),
      headlineSmall: GoogleFonts.playfairDisplay(textStyle: corps.headlineSmall),
      titleLarge: GoogleFonts.playfairDisplay(textStyle: corps.titleLarge),
    );
  }

  /// Style dédié aux citations / proverbes (Cormorant Garamond, italique).
  static TextStyle citation(BuildContext context) => GoogleFonts.cormorantGaramond(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
      );
}
```

- [ ] **Step 3: Vérifier l'analyse**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter analyze lib/core/theme
```
Expected: « No issues found! ».

- [ ] **Step 4: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/core/theme
git commit -m "feat: palette et thème clair/sombre Kabary"
```

---

## Task 3: Modèles de données + assets JSON

**Files:**
- Create: `lib/features/bibliotheque/data/kabary.dart`
- Create: `lib/features/ohabolana/data/ohabolana.dart`
- Create: `assets/data/kabary.json`
- Create: `assets/data/ohabolana.json`
- Modify: `pubspec.yaml` (déclaration des assets)

- [ ] **Step 1: Modèle Kabary**

`lib/features/bibliotheque/data/kabary.dart`:
```dart
/// Section d'un kabary (texte malgache + traduction française).
class KabarySection {
  final String titre;
  final String contenuMg;
  final String traductionFr;

  const KabarySection({
    required this.titre,
    required this.contenuMg,
    required this.traductionFr,
  });

  factory KabarySection.fromJson(Map<String, dynamic> json) => KabarySection(
        titre: json['titre'] as String,
        contenuMg: json['contenuMg'] as String,
        traductionFr: json['traductionFr'] as String,
      );

  Map<String, dynamic> toJson() => {
        'titre': titre,
        'contenuMg': contenuMg,
        'traductionFr': traductionFr,
      };
}

/// Un kabary (discours oratoire) classé par occasion.
class Kabary {
  final String id;
  final String titre;
  final String occasion;
  final String region;
  final int dureeMinutes;
  final String niveau;
  final List<KabarySection> sections;
  final List<String> ohabolanaIds;

  const Kabary({
    required this.id,
    required this.titre,
    required this.occasion,
    required this.region,
    required this.dureeMinutes,
    required this.niveau,
    required this.sections,
    required this.ohabolanaIds,
  });

  factory Kabary.fromJson(Map<String, dynamic> json) => Kabary(
        id: json['id'] as String,
        titre: json['titre'] as String,
        occasion: json['occasion'] as String,
        region: json['region'] as String,
        dureeMinutes: json['dureeMinutes'] as int,
        niveau: json['niveau'] as String,
        sections: (json['sections'] as List)
            .map((e) => KabarySection.fromJson(e as Map<String, dynamic>))
            .toList(),
        ohabolanaIds:
            (json['ohabolanaIds'] as List).map((e) => e as String).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'occasion': occasion,
        'region': region,
        'dureeMinutes': dureeMinutes,
        'niveau': niveau,
        'sections': sections.map((e) => e.toJson()).toList(),
        'ohabolanaIds': ohabolanaIds,
      };
}
```

- [ ] **Step 2: Modèle Ohabolana**

`lib/features/ohabolana/data/ohabolana.dart`:
```dart
/// Un proverbe malgache (ohabolana).
class Ohabolana {
  final String id;
  final String texteMg;
  final String? translitteration;
  final String traductionFr;
  final String? signification;
  final List<String> themes;
  final String? usage;

  const Ohabolana({
    required this.id,
    required this.texteMg,
    this.translitteration,
    required this.traductionFr,
    this.signification,
    required this.themes,
    this.usage,
  });

  factory Ohabolana.fromJson(Map<String, dynamic> json) => Ohabolana(
        id: json['id'] as String,
        texteMg: json['texteMg'] as String,
        translitteration: json['translitteration'] as String?,
        traductionFr: json['traductionFr'] as String,
        signification: json['signification'] as String?,
        themes: (json['themes'] as List).map((e) => e as String).toList(),
        usage: json['usage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'texteMg': texteMg,
        'translitteration': translitteration,
        'traductionFr': traductionFr,
        'signification': signification,
        'themes': themes,
        'usage': usage,
      };
}
```

- [ ] **Step 3: Données d'exemple ohabolana**

`assets/data/ohabolana.json`:
```json
[
  {
    "id": "oha-001",
    "texteMg": "Ny fihavanana no tsy mba azo vidina vola.",
    "translitteration": "ni fi-ha-VA-na-na nu tsi ba a-zu VI-di-na VU-la",
    "traductionFr": "La solidarité (fihavanana) ne s'achète pas avec de l'argent.",
    "signification": "La valeur des liens humains dépasse toute richesse matérielle.",
    "themes": ["fihavanana", "communauté", "sagesse"],
    "usage": "Ouverture d'un kabary de mariage ou de réconciliation."
  },
  {
    "id": "oha-002",
    "texteMg": "Ny teny ierana tsy mba diso.",
    "translitteration": "ni TE-ni i-e-RA-na tsi ba DI-su",
    "traductionFr": "La parole concertée ne se trompe pas.",
    "signification": "Les décisions prises en commun sont les plus justes.",
    "themes": ["communauté", "sagesse", "respect"],
    "usage": "Dans un kabary de réunion communautaire (fihaonana)."
  },
  {
    "id": "oha-003",
    "texteMg": "Ny marina tsy mba maty.",
    "translitteration": "ni MA-ri-na tsi ba MA-ti",
    "traductionFr": "La vérité ne meurt jamais.",
    "signification": "La vérité finit toujours par triompher avec le temps.",
    "themes": ["sagesse", "vérité"],
    "usage": "Pour appuyer un argument moral dans le corps du discours."
  },
  {
    "id": "oha-004",
    "texteMg": "Izay mahay miteny mahay mandresy.",
    "translitteration": "i-zai ma-HAI mi-TE-ni ma-HAI man-DRE-si",
    "traductionFr": "Qui sait parler sait vaincre.",
    "signification": "La maîtrise de la parole est une force décisive.",
    "themes": ["parole", "sagesse"],
    "usage": "Introduction d'un kabary mettant en valeur l'art oratoire."
  },
  {
    "id": "oha-005",
    "texteMg": "Ny hazo no vanon-ko lakana, ny tany naniriany no tsara.",
    "translitteration": "ni HA-zu nu va-non-ku la-KA-na, ni TA-ni na-ni-RI-an nu TSA-ra",
    "traductionFr": "Si l'arbre devient une belle pirogue, c'est que la terre qui l'a nourri était bonne.",
    "signification": "La réussite d'une personne reflète son éducation et son entourage.",
    "themes": ["famille", "nature", "éducation"],
    "usage": "Éloge des parents dans un kabary de mariage."
  },
  {
    "id": "oha-006",
    "texteMg": "Ny atao no miverina, ny natao no mody.",
    "translitteration": "ni a-TAU nu mi-ve-RI-na, ni na-TAU nu MU-di",
    "traductionFr": "Ce que l'on fait revient, ce que l'on a fait retourne (à soi).",
    "signification": "Toute action a des conséquences qui reviennent à son auteur.",
    "themes": ["sagesse", "morale"],
    "usage": "Avertissement moral dans le corps d'un kabary."
  },
  {
    "id": "oha-007",
    "texteMg": "Fihavanana mihoatra ny harena.",
    "translitteration": "fi-ha-VA-na-na mi-HU-tra ni ha-RE-na",
    "traductionFr": "La solidarité vaut plus que la richesse.",
    "signification": "Les liens humains priment sur les biens matériels.",
    "themes": ["fihavanana", "communauté"],
    "usage": "Conclusion d'un kabary appelant à l'unité."
  },
  {
    "id": "oha-008",
    "texteMg": "Aleo maty rahampitso toy izay maty androany.",
    "translitteration": "a-LE-u MA-ti ra-ham-PI-tsu tui i-zai MA-ti an-DRU-a-ni",
    "traductionFr": "Mieux vaut mourir demain qu'aujourd'hui.",
    "signification": "Il faut préférer la patience et l'espoir à la précipitation.",
    "themes": ["sagesse", "patience"],
    "usage": "Pour inviter à la prudence dans une négociation."
  },
  {
    "id": "oha-009",
    "texteMg": "Ny voky tsy mahaleo ny noana.",
    "translitteration": "ni VU-ki tsi ma-ha-LE-u ni NU-a-na",
    "traductionFr": "Le rassasié ne comprend pas l'affamé.",
    "signification": "On ne ressent pas la souffrance que l'on ne vit pas soi-même.",
    "themes": ["sagesse", "empathie", "communauté"],
    "usage": "Appel à la solidarité envers les plus démunis."
  },
  {
    "id": "oha-010",
    "texteMg": "Ny fitiavana tsy mahalala fahasahiranana.",
    "translitteration": "ni fi-ti-A-va-na tsi ma-ha-LA-la fa-ha-sa-hi-RA-na-na",
    "traductionFr": "L'amour ne connaît pas la peine.",
    "signification": "Quand on aime, aucun effort ne paraît pénible.",
    "themes": ["amour", "famille"],
    "usage": "Éloge des mariés dans un kabary de mariage."
  },
  {
    "id": "oha-011",
    "texteMg": "Tsy misy mahalala ny ho avy.",
    "translitteration": "tsi MI-si ma-ha-LA-la ni hu A-vi",
    "traductionFr": "Nul ne connaît l'avenir.",
    "signification": "L'humilité s'impose face à l'incertitude de la vie.",
    "themes": ["sagesse", "humilité"],
    "usage": "Transition vers les vœux dans un kabary."
  },
  {
    "id": "oha-012",
    "texteMg": "Ny teny malefaka mandresy ny mafy.",
    "translitteration": "ni TE-ni ma-LE-fa-ka man-DRE-si ni MA-fi",
    "traductionFr": "La parole douce vainc la dureté.",
    "signification": "La douceur et la diplomatie sont plus efficaces que la force.",
    "themes": ["parole", "respect", "sagesse"],
    "usage": "Ouverture conciliante d'un kabary de demande (fangatahana)."
  }
]
```

- [ ] **Step 4: Données d'exemple kabary**

`assets/data/kabary.json`:
```json
[
  {
    "id": "kab-001",
    "titre": "Kabary fanambadiana — demande de la mariée",
    "occasion": "Fanambadiana",
    "region": "Imerina",
    "dureeMinutes": 15,
    "niveau": "Intermédiaire",
    "ohabolanaIds": ["oha-001", "oha-005", "oha-010"],
    "sections": [
      {
        "titre": "Fiarahana (Salutation)",
        "contenuMg": "Tompokolahy sy tompokovavy, arahaba tratry ny andro. Misaotra anareo tonga maro fa ny fihavanana no nentinay teto.",
        "traductionFr": "Mesdames et messieurs, bonjour à tous. Merci d'être venus nombreux, car c'est la solidarité qui nous a réunis ici."
      },
      {
        "titre": "Fampidirana (Introduction)",
        "contenuMg": "Tonga izahay anio hangataka, fa ny fihavanana no tsy mba azo vidina vola.",
        "traductionFr": "Nous venons aujourd'hui faire une demande, car la solidarité ne s'achète pas avec de l'argent."
      },
      {
        "titre": "Vohitra (Corps du discours)",
        "contenuMg": "Indreto izahay mpaka voninkazo, fa ny hazo no vanon-ko lakana, ny tany naniriany no tsara.",
        "traductionFr": "Nous voici venus cueillir une fleur, car si l'arbre devient une belle pirogue, c'est que la terre qui l'a nourri était bonne."
      },
      {
        "titre": "Farany (Conclusion)",
        "contenuMg": "Koa enga anie ka hotahian'Andriamanitra ity fanambadiana ity. Misaotra tompokolahy sy tompokovavy.",
        "traductionFr": "Puisse Dieu bénir cette union. Merci à toutes et à tous."
      }
    ]
  },
  {
    "id": "kab-002",
    "titre": "Kabary fisaorana — remerciements",
    "occasion": "Fisaorana",
    "region": "Betsileo",
    "dureeMinutes": 8,
    "niveau": "Débutant",
    "ohabolanaIds": ["oha-007", "oha-002"],
    "sections": [
      {
        "titre": "Fiarahana (Salutation)",
        "contenuMg": "Arahaba tompokolahy sy tompokovavy rehetra. Faly izahay mahita anareo eto.",
        "traductionFr": "Bonjour à toutes et à tous. Nous sommes heureux de vous voir ici."
      },
      {
        "titre": "Vohitra (Corps du discours)",
        "contenuMg": "Misaotra anareo izahay, fa fihavanana mihoatra ny harena no nasehonareo.",
        "traductionFr": "Nous vous remercions, car vous avez montré que la solidarité vaut plus que la richesse."
      },
      {
        "titre": "Farany (Conclusion)",
        "contenuMg": "Ho ela velona anie isika rehetra. Misaotra indrindra.",
        "traductionFr": "Puissions-nous tous vivre longtemps. Merci infiniment."
      }
    ]
  },
  {
    "id": "kab-003",
    "titre": "Kabary fihaonana — réunion communautaire",
    "occasion": "Fihaonana",
    "region": "Imerina",
    "dureeMinutes": 12,
    "niveau": "Intermédiaire",
    "ohabolanaIds": ["oha-002", "oha-009"],
    "sections": [
      {
        "titre": "Fiarahana (Salutation)",
        "contenuMg": "Tompokolahy sy tompokovavy, samia tratran'izao fotoana izao.",
        "traductionFr": "Mesdames et messieurs, soyez tous les bienvenus en ce jour."
      },
      {
        "titre": "Fampidirana (Introduction)",
        "contenuMg": "Tonga isika hifampidinika, fa ny teny ierana tsy mba diso.",
        "traductionFr": "Nous sommes réunis pour délibérer, car la parole concertée ne se trompe pas."
      },
      {
        "titre": "Farany (Conclusion)",
        "contenuMg": "Aoka isika hiray hina, fa ny voky tsy mahaleo ny noana.",
        "traductionFr": "Soyons unis, car le rassasié ne comprend pas l'affamé."
      }
    ]
  }
]
```

- [ ] **Step 5: Déclarer les assets dans pubspec.yaml**

Dans `pubspec.yaml`, sous la section `flutter:`, ajouter (en respectant l'indentation YAML existante générée par `flutter create`) :
```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/data/kabary.json
    - assets/data/ohabolana.json
```

- [ ] **Step 6: Vérifier l'analyse et le pub get**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter pub get && /home/happy/flutter/bin/flutter analyze lib
```
Expected: pub get OK, « No issues found! ».

- [ ] **Step 7: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features pubspec.yaml assets/data
git commit -m "feat: modèles Kabary/Ohabolana + données d'exemple embarquées"
```

---

## Task 4: SeedService (TDD)

**Files:**
- Create: `lib/core/data/seed_service.dart`
- Test: `test/seed_service_test.dart`

- [ ] **Step 1: Écrire le test qui échoue**

`test/seed_service_test.dart`:
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kabary/core/data/seed_service.dart';

void main() {
  late Directory tempDir;
  late Box kabaryBox;
  late Box ohabolanaBox;
  late Box metaBox;

  const kabaryJson = '''
  [{"id":"k1","titre":"T","occasion":"Fisaorana","region":"Imerina",
    "dureeMinutes":5,"niveau":"Débutant","ohabolanaIds":["o1"],
    "sections":[{"titre":"S","contenuMg":"mg","traductionFr":"fr"}]}]
  ''';
  const ohabolanaJson = '''
  [{"id":"o1","texteMg":"mg","traductionFr":"fr","themes":["sagesse"]}]
  ''';

  Future<String> fakeReader(String path) async {
    if (path.contains('kabary')) return kabaryJson;
    if (path.contains('ohabolana')) return ohabolanaJson;
    throw ArgumentError('unknown asset: $path');
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kabary_seed_test');
    Hive.init(tempDir.path);
    kabaryBox = await Hive.openBox('kabary');
    ohabolanaBox = await Hive.openBox('ohabolana');
    metaBox = await Hive.openBox('meta');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('seeds kabary and ohabolana on first run', () async {
    final seed = SeedService(
      kabaryBox: kabaryBox,
      ohabolanaBox: ohabolanaBox,
      metaBox: metaBox,
      readAsset: fakeReader,
    );

    await seed.seedIfNeeded();

    expect(kabaryBox.length, 1);
    expect(ohabolanaBox.length, 1);
    expect(metaBox.get('seeded'), true);
  });

  test('does not seed twice (idempotent)', () async {
    final seed = SeedService(
      kabaryBox: kabaryBox,
      ohabolanaBox: ohabolanaBox,
      metaBox: metaBox,
      readAsset: fakeReader,
    );

    await seed.seedIfNeeded();
    await seed.seedIfNeeded();

    expect(kabaryBox.length, 1);
  });
}
```

- [ ] **Step 2: Lancer le test pour vérifier qu'il échoue**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/seed_service_test.dart
```
Expected: échec de compilation — `seed_service.dart` n'existe pas / `SeedService` introuvable.

- [ ] **Step 3: Implémenter le SeedService**

`lib/core/data/seed_service.dart`:
```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../features/bibliotheque/data/kabary.dart';
import '../../features/ohabolana/data/ohabolana.dart';

/// Lit une ressource (asset) et renvoie son contenu texte.
typedef AssetReader = Future<String> Function(String path);

/// Peuple Hive depuis les fichiers JSON embarqués, une seule fois.
class SeedService {
  final Box kabaryBox;
  final Box ohabolanaBox;
  final Box metaBox;
  final AssetReader readAsset;

  SeedService({
    required this.kabaryBox,
    required this.ohabolanaBox,
    required this.metaBox,
    required this.readAsset,
  });

  Future<void> seedIfNeeded() async {
    if (metaBox.get('seeded') == true) return;

    final kabaryRaw = jsonDecode(await readAsset('assets/data/kabary.json'))
        as List<dynamic>;
    for (final item in kabaryRaw) {
      final k = Kabary.fromJson(item as Map<String, dynamic>);
      await kabaryBox.put(k.id, jsonEncode(k.toJson()));
    }

    final ohabolanaRaw =
        jsonDecode(await readAsset('assets/data/ohabolana.json'))
            as List<dynamic>;
    for (final item in ohabolanaRaw) {
      final o = Ohabolana.fromJson(item as Map<String, dynamic>);
      await ohabolanaBox.put(o.id, jsonEncode(o.toJson()));
    }

    await metaBox.put('seeded', true);
  }
}
```

- [ ] **Step 4: Lancer le test pour vérifier qu'il passe**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/seed_service_test.dart
```
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/core/data/seed_service.dart test/seed_service_test.dart
git commit -m "feat: SeedService JSON→Hive idempotent (TDD)"
```

---

## Task 5: KabaryRepository (TDD)

**Files:**
- Create: `lib/features/bibliotheque/data/kabary_repository.dart`
- Test: `test/kabary_repository_test.dart`

- [ ] **Step 1: Écrire le test qui échoue**

`test/kabary_repository_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kabary/features/bibliotheque/data/kabary.dart';
import 'package:kabary/features/bibliotheque/data/kabary_repository.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late KabaryRepository repo;

  Kabary make(String id, String occasion, String region, String niveau) =>
      Kabary(
        id: id,
        titre: 'Titre $id',
        occasion: occasion,
        region: region,
        dureeMinutes: 10,
        niveau: niveau,
        sections: const [
          KabarySection(titre: 'S', contenuMg: 'mg', traductionFr: 'fr'),
        ],
        ohabolanaIds: const [],
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kabary_repo_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox('kabary');
    for (final k in [
      make('k1', 'Fanambadiana', 'Imerina', 'Débutant'),
      make('k2', 'Fisaorana', 'Betsileo', 'Intermédiaire'),
      make('k3', 'Fanambadiana', 'Betsileo', 'Débutant'),
    ]) {
      await box.put(k.id, jsonEncode(k.toJson()));
    }
    repo = KabaryRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('getAll returns all kabary', () {
    expect(repo.getAll().length, 3);
  });

  test('getById returns the right kabary', () {
    expect(repo.getById('k2')?.occasion, 'Fisaorana');
    expect(repo.getById('absent'), isNull);
  });

  test('filter by occasion', () {
    final r = repo.filter(occasion: 'Fanambadiana');
    expect(r.map((k) => k.id), containsAll(['k1', 'k3']));
    expect(r.length, 2);
  });

  test('filter by region and niveau combined', () {
    final r = repo.filter(region: 'Betsileo', niveau: 'Débutant');
    expect(r.single.id, 'k3');
  });
}
```

- [ ] **Step 2: Lancer le test pour vérifier qu'il échoue**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/kabary_repository_test.dart
```
Expected: échec — `KabaryRepository` introuvable.

- [ ] **Step 3: Implémenter le repository**

`lib/features/bibliotheque/data/kabary_repository.dart`:
```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/data/providers.dart';
import 'kabary.dart';

/// Accès local aux kabary stockés dans Hive (JSON encodé).
class KabaryRepository {
  final Box box;
  KabaryRepository(this.box);

  List<Kabary> getAll() => box.values
      .map((e) => Kabary.fromJson(
          jsonDecode(e as String) as Map<String, dynamic>))
      .toList();

  Kabary? getById(String id) {
    final raw = box.get(id);
    if (raw == null) return null;
    return Kabary.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
  }

  List<Kabary> filter({String? occasion, String? region, String? niveau}) {
    return getAll().where((k) {
      if (occasion != null && k.occasion != occasion) return false;
      if (region != null && k.region != region) return false;
      if (niveau != null && k.niveau != niveau) return false;
      return true;
    }).toList();
  }
}

/// Repository fourni via le provider de Box (voir core/data/providers.dart).
final kabaryRepositoryProvider = Provider<KabaryRepository>(
  (ref) => KabaryRepository(ref.watch(kabaryBoxProvider)),
);
```

- [ ] **Step 4: Créer les providers de Box partagés**

`lib/core/data/providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Boxes Hive. Surchargés dans main() avec les boxes réellement ouvertes.
final kabaryBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('kabaryBoxProvider doit être surchargé'),
);
final ohabolanaBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('ohabolanaBoxProvider doit être surchargé'),
);
final favorisBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('favorisBoxProvider doit être surchargé'),
);
```

- [ ] **Step 5: Lancer le test pour vérifier qu'il passe**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/kabary_repository_test.dart
```
Expected: PASS (4 tests).

- [ ] **Step 6: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/bibliotheque/data/kabary_repository.dart lib/core/data/providers.dart test/kabary_repository_test.dart
git commit -m "feat: KabaryRepository (getAll/getById/filter) + providers de Box (TDD)"
```

---

## Task 6: OhabolanaRepository (TDD)

**Files:**
- Create: `lib/features/ohabolana/data/ohabolana_repository.dart`
- Test: `test/ohabolana_repository_test.dart`

- [ ] **Step 1: Écrire le test qui échoue**

`test/ohabolana_repository_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kabary/features/ohabolana/data/ohabolana.dart';
import 'package:kabary/features/ohabolana/data/ohabolana_repository.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late OhabolanaRepository repo;

  Ohabolana make(String id, String mg, String fr, List<String> themes) =>
      Ohabolana(id: id, texteMg: mg, traductionFr: fr, themes: themes);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('oha_repo_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox('ohabolana');
    for (final o in [
      make('o1', 'Ny fihavanana', 'La solidarité', ['fihavanana']),
      make('o2', 'Ny marina tsy maty', 'La vérité ne meurt', ['sagesse']),
      make('o3', 'Ny teny malefaka', 'La parole douce', ['parole', 'sagesse']),
    ]) {
      await box.put(o.id, jsonEncode(o.toJson()));
    }
    repo = OhabolanaRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('getAll returns all', () {
    expect(repo.getAll().length, 3);
  });

  test('search matches malagasy or french text (case-insensitive)', () {
    expect(repo.search('VÉRITÉ').single.id, 'o2');
    expect(repo.search('teny').single.id, 'o3');
  });

  test('search by theme', () {
    expect(repo.search('sagesse').map((o) => o.id),
        containsAll(['o2', 'o3']));
  });

  test('proverbeDuJour is deterministic for a given date', () {
    final a = repo.proverbeDuJour(DateTime(2026, 6, 29));
    final b = repo.proverbeDuJour(DateTime(2026, 6, 29));
    expect(a.id, b.id);
  });
}
```

- [ ] **Step 2: Lancer le test pour vérifier qu'il échoue**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/ohabolana_repository_test.dart
```
Expected: échec — `OhabolanaRepository` introuvable.

- [ ] **Step 3: Implémenter le repository**

`lib/features/ohabolana/data/ohabolana_repository.dart`:
```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/data/providers.dart';
import 'ohabolana.dart';

/// Accès local aux ohabolana stockés dans Hive (JSON encodé).
class OhabolanaRepository {
  final Box box;
  OhabolanaRepository(this.box);

  List<Ohabolana> getAll() => box.values
      .map((e) => Ohabolana.fromJson(
          jsonDecode(e as String) as Map<String, dynamic>))
      .toList();

  Ohabolana? getById(String id) {
    final raw = box.get(id);
    if (raw == null) return null;
    return Ohabolana.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>);
  }

  /// Recherche insensible à la casse sur le texte mg, la traduction et les thèmes.
  List<Ohabolana> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    return getAll().where((o) {
      final haystack = [
        o.texteMg,
        o.traductionFr,
        o.signification ?? '',
        o.usage ?? '',
        ...o.themes,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  /// Proverbe du jour : sélection déterministe basée sur la date.
  Ohabolana proverbeDuJour(DateTime date) {
    final all = getAll();
    final index = (date.year * 1000 + date.month * 50 + date.day) % all.length;
    return all[index];
  }
}

final ohabolanaRepositoryProvider = Provider<OhabolanaRepository>(
  (ref) => OhabolanaRepository(ref.watch(ohabolanaBoxProvider)),
);
```

- [ ] **Step 4: Lancer le test pour vérifier qu'il passe**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/ohabolana_repository_test.dart
```
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/ohabolana/data/ohabolana_repository.dart test/ohabolana_repository_test.dart
git commit -m "feat: OhabolanaRepository (getAll/search/proverbeDuJour) (TDD)"
```

---

## Task 7: FavorisRepository + Notifier (TDD)

**Files:**
- Create: `lib/features/favoris/data/favoris_repository.dart`
- Test: `test/favoris_repository_test.dart`

- [ ] **Step 1: Écrire le test qui échoue**

`test/favoris_repository_test.dart`:
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kabary/features/favoris/data/favoris_repository.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late FavorisRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('favoris_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox('favoris');
    repo = FavorisRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('toggle adds then removes a kabary favori', () async {
    expect(repo.isKabaryFavori('k1'), isFalse);
    await repo.toggleKabary('k1');
    expect(repo.isKabaryFavori('k1'), isTrue);
    expect(repo.kabaryIds(), ['k1']);
    await repo.toggleKabary('k1');
    expect(repo.isKabaryFavori('k1'), isFalse);
  });

  test('kabary and ohabolana favoris are independent', () async {
    await repo.toggleKabary('k1');
    await repo.toggleOhabolana('o1');
    expect(repo.kabaryIds(), ['k1']);
    expect(repo.ohabolanaIds(), ['o1']);
  });

  test('persists across repository instances on same box', () async {
    await repo.toggleOhabolana('o2');
    final repo2 = FavorisRepository(box);
    expect(repo2.isOhabolanaFavori('o2'), isTrue);
  });
}
```

- [ ] **Step 2: Lancer le test pour vérifier qu'il échoue**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/favoris_repository_test.dart
```
Expected: échec — `FavorisRepository` introuvable.

- [ ] **Step 3: Implémenter le repository + Notifier**

`lib/features/favoris/data/favoris_repository.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/data/providers.dart';

/// Gère les favoris locaux (deux listes : kabary et ohabolana) dans Hive.
class FavorisRepository {
  final Box box;
  FavorisRepository(this.box);

  static const _kKabary = 'favorisKabary';
  static const _kOhabolana = 'favorisOhabolana';

  List<String> kabaryIds() =>
      (box.get(_kKabary) as List?)?.cast<String>() ?? <String>[];

  List<String> ohabolanaIds() =>
      (box.get(_kOhabolana) as List?)?.cast<String>() ?? <String>[];

  bool isKabaryFavori(String id) => kabaryIds().contains(id);
  bool isOhabolanaFavori(String id) => ohabolanaIds().contains(id);

  Future<void> toggleKabary(String id) async {
    final ids = kabaryIds();
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    await box.put(_kKabary, ids);
  }

  Future<void> toggleOhabolana(String id) async {
    final ids = ohabolanaIds();
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    await box.put(_kOhabolana, ids);
  }
}

/// État immuable des favoris pour l'UI.
class FavorisState {
  final Set<String> kabary;
  final Set<String> ohabolana;
  const FavorisState({required this.kabary, required this.ohabolana});
}

/// Notifier exposant les favoris et déclenchant les rebuilds à chaque toggle.
class FavorisNotifier extends Notifier<FavorisState> {
  late final FavorisRepository _repo;

  @override
  FavorisState build() {
    _repo = FavorisRepository(ref.watch(favorisBoxProvider));
    return _snapshot();
  }

  FavorisState _snapshot() => FavorisState(
        kabary: _repo.kabaryIds().toSet(),
        ohabolana: _repo.ohabolanaIds().toSet(),
      );

  Future<void> toggleKabary(String id) async {
    await _repo.toggleKabary(id);
    state = _snapshot();
  }

  Future<void> toggleOhabolana(String id) async {
    await _repo.toggleOhabolana(id);
    state = _snapshot();
  }
}

final favorisProvider =
    NotifierProvider<FavorisNotifier, FavorisState>(FavorisNotifier.new);
```

- [ ] **Step 4: Lancer le test pour vérifier qu'il passe**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/favoris_repository_test.dart
```
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/favoris/data/favoris_repository.dart test/favoris_repository_test.dart
git commit -m "feat: FavorisRepository + FavorisNotifier (TDD)"
```

---

## Task 8: Router + coquille bottom navigation

**Files:**
- Create: `lib/core/widgets/app_scaffold.dart`
- Create: `lib/core/router/app_router.dart`
- Create: stubs minimaux de pages (remplacés aux tâches suivantes) :
  `lib/features/accueil/presentation/accueil_page.dart`,
  `lib/features/bibliotheque/presentation/bibliotheque_page.dart`,
  `lib/features/bibliotheque/presentation/kabary_detail_page.dart`,
  `lib/features/ohabolana/presentation/ohabolana_page.dart`,
  `lib/features/ohabolana/presentation/ohabolana_detail_page.dart`,
  `lib/features/favoris/presentation/favoris_page.dart`

- [ ] **Step 1: Créer les stubs de pages**

Chaque fichier ci-dessous est un stub temporaire. Les pages Accueil/Bibliothèque/Ohabolana/Favoris seront complétées aux tâches 9-12 ; les pages de détail reçoivent leur `id` via le routeur.

`lib/features/accueil/presentation/accueil_page.dart`:
```dart
import 'package:flutter/material.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Accueil'));
}
```

`lib/features/bibliotheque/presentation/bibliotheque_page.dart`:
```dart
import 'package:flutter/material.dart';

class BibliothequePage extends StatelessWidget {
  const BibliothequePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Bibliothèque'));
}
```

`lib/features/bibliotheque/presentation/kabary_detail_page.dart`:
```dart
import 'package:flutter/material.dart';

class KabaryDetailPage extends StatelessWidget {
  final String kabaryId;
  const KabaryDetailPage({super.key, required this.kabaryId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text(kabaryId)));
}
```

`lib/features/ohabolana/presentation/ohabolana_page.dart`:
```dart
import 'package:flutter/material.dart';

class OhabolanaPage extends StatelessWidget {
  const OhabolanaPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Ohabolana'));
}
```

`lib/features/ohabolana/presentation/ohabolana_detail_page.dart`:
```dart
import 'package:flutter/material.dart';

class OhabolanaDetailPage extends StatelessWidget {
  final String ohabolanaId;
  const OhabolanaDetailPage({super.key, required this.ohabolanaId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: Center(child: Text(ohabolanaId)));
}
```

`lib/features/favoris/presentation/favoris_page.dart`:
```dart
import 'package:flutter/material.dart';

class FavorisPage extends StatelessWidget {
  const FavorisPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Favoris'));
}
```

- [ ] **Step 2: Créer la coquille bottom navigation**

`lib/core/widgets/app_scaffold.dart`:
```dart
import 'package:flutter/material.dart';

/// Coquille hébergeant les 4 onglets et la barre de navigation basse.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Bibliothèque'),
          NavigationDestination(icon: Icon(Icons.spa_outlined), label: 'Ohabolana'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'Favoris'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Créer le routeur**

`lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/accueil/presentation/accueil_page.dart';
import '../../features/bibliotheque/presentation/bibliotheque_page.dart';
import '../../features/bibliotheque/presentation/kabary_detail_page.dart';
import '../../features/ohabolana/presentation/ohabolana_page.dart';
import '../../features/ohabolana/presentation/ohabolana_detail_page.dart';
import '../../features/favoris/presentation/favoris_page.dart';
import '../widgets/app_scaffold.dart';

/// Onglets de la barre de navigation, dans l'ordre.
const _tabs = ['/accueil', '/bibliotheque', '/ohabolana', '/favoris'];

int _indexForLocation(String location) {
  final i = _tabs.indexWhere((t) => location.startsWith(t));
  return i < 0 ? 0 : i;
}

final appRouter = GoRouter(
  initialLocation: '/accueil',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(
        currentIndex: _indexForLocation(state.uri.path),
        onTap: (i) => context.go(_tabs[i]),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/accueil',
          builder: (context, state) => const AccueilPage(),
        ),
        GoRoute(
          path: '/bibliotheque',
          builder: (context, state) => const BibliothequePage(),
          routes: [
            GoRoute(
              path: 'kabary/:id',
              builder: (context, state) =>
                  KabaryDetailPage(kabaryId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/ohabolana',
          builder: (context, state) => const OhabolanaPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  OhabolanaDetailPage(ohabolanaId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/favoris',
          builder: (context, state) => const FavorisPage(),
        ),
      ],
    ),
  ],
);
```

- [ ] **Step 4: Écrire main.dart**

`lib/main.dart` (remplacer intégralement le contenu généré) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/data/providers.dart';
import 'core/data/seed_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final kabaryBox = await Hive.openBox('kabary');
  final ohabolanaBox = await Hive.openBox('ohabolana');
  final favorisBox = await Hive.openBox('favoris');
  final metaBox = await Hive.openBox('meta');

  await SeedService(
    kabaryBox: kabaryBox,
    ohabolanaBox: ohabolanaBox,
    metaBox: metaBox,
    readAsset: rootBundle.loadString,
  ).seedIfNeeded();

  runApp(
    ProviderScope(
      overrides: [
        kabaryBoxProvider.overrideWithValue(kabaryBox),
        ohabolanaBoxProvider.overrideWithValue(ohabolanaBox),
        favorisBoxProvider.overrideWithValue(favorisBox),
      ],
      child: const KabaryApp(),
    ),
  );
}

class KabaryApp extends StatelessWidget {
  const KabaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kabary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      darkTheme: AppTheme.sombre,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 5: Supprimer le test widget par défaut**

Le `flutter create` génère `test/widget_test.dart` qui référence l'ancien `MyApp` et casse la compilation des tests.

Run:
```bash
cd /home/happy/Documents/Joann/KbR && rm -f test/widget_test.dart
```

- [ ] **Step 6: Vérifier l'analyse et lancer toute la suite de tests**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter analyze && /home/happy/flutter/bin/flutter test
```
Expected: « No issues found! » puis tous les tests PASS (seed, kabary, ohabolana, favoris).

- [ ] **Step 7: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/ test/
git commit -m "feat: router go_router + bottom nav + bootstrap Hive/seed dans main"
```

---

## Task 9: Page Accueil (TDD widget)

**Files:**
- Modify: `lib/features/accueil/presentation/accueil_page.dart`
- Test: `test/accueil_page_test.dart`

- [ ] **Step 1: Écrire le test widget qui échoue**

`test/accueil_page_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kabary/core/data/providers.dart';
import 'package:kabary/features/accueil/presentation/accueil_page.dart';
import 'package:kabary/features/ohabolana/data/ohabolana.dart';

void main() {
  late Directory tempDir;
  late Box ohabolanaBox;
  late Box kabaryBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('accueil_test');
    Hive.init(tempDir.path);
    ohabolanaBox = await Hive.openBox('ohabolana');
    kabaryBox = await Hive.openBox('kabary');
    const o = Ohabolana(
      id: 'o1',
      texteMg: 'Ny fihavanana no tsy mba azo vidina vola.',
      traductionFr: 'La solidarité ne s\'achète pas.',
      themes: ['fihavanana'],
    );
    await ohabolanaBox.put(o.id, jsonEncode(o.toJson()));
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('affiche le proverbe du jour', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ohabolanaBoxProvider.overrideWithValue(ohabolanaBox),
          kabaryBoxProvider.overrideWithValue(kabaryBox),
        ],
        child: const MaterialApp(home: Scaffold(body: AccueilPage())),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Ohabolana du jour'), findsOneWidget);
    expect(
      find.textContaining('Ny fihavanana no tsy mba azo vidina vola.'),
      findsOneWidget,
    );
  });
}
```

- [ ] **Step 2: Lancer le test pour vérifier qu'il échoue**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/accueil_page_test.dart
```
Expected: échec — le stub Accueil n'affiche pas « Ohabolana du jour ».

- [ ] **Step 3: Implémenter la page Accueil**

`lib/features/accueil/presentation/accueil_page.dart` (remplacer le stub) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../bibliotheque/data/kabary_repository.dart';
import '../../ohabolana/data/ohabolana_repository.dart';

class AccueilPage extends ConsumerWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proverbe =
        ref.watch(ohabolanaRepositoryProvider).proverbeDuJour(DateTime.now());
    final kabaryRecents = ref.watch(kabaryRepositoryProvider).getAll();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kabary', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        Text('Ohabolana du jour',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proverbe.texteMg, style: AppTheme.citation(context)),
                const SizedBox(height: 8),
                Text(proverbe.traductionFr,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Kabary récents',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...kabaryRecents.map(
          (k) => Card(
            child: ListTile(
              title: Text(k.titre),
              subtitle: Text('${k.occasion} • ${k.region}'),
              onTap: () => context.go('/bibliotheque/kabary/${k.id}'),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Lancer le test pour vérifier qu'il passe**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test test/accueil_page_test.dart
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/accueil test/accueil_page_test.dart
git commit -m "feat: page Accueil (proverbe du jour + kabary récents) (TDD)"
```

---

## Task 10: Page Bibliothèque + détail kabary

**Files:**
- Modify: `lib/features/bibliotheque/presentation/bibliotheque_page.dart`
- Modify: `lib/features/bibliotheque/presentation/kabary_detail_page.dart`

- [ ] **Step 1: Implémenter la liste Bibliothèque avec filtres**

`lib/features/bibliotheque/presentation/bibliotheque_page.dart` (remplacer le stub) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/kabary_repository.dart';

/// État du filtre d'occasion sélectionné (null = toutes).
final occasionFiltreProvider = StateProvider<String?>((ref) => null);

class BibliothequePage extends ConsumerWidget {
  const BibliothequePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(kabaryRepositoryProvider);
    final occasion = ref.watch(occasionFiltreProvider);
    final kabary = repo.filter(occasion: occasion);

    final occasions =
        repo.getAll().map((k) => k.occasion).toSet().toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Bibliothèque',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Toutes'),
                  selected: occasion == null,
                  onSelected: (_) =>
                      ref.read(occasionFiltreProvider.notifier).state = null,
                ),
              ),
              ...occasions.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: occasion == o,
                    onSelected: (_) =>
                        ref.read(occasionFiltreProvider.notifier).state = o,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: kabary.length,
            itemBuilder: (context, i) {
              final k = kabary[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(k.titre),
                  subtitle: Text(
                      '${k.occasion} • ${k.region} • ${k.niveau} • ~${k.dureeMinutes} min'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/bibliotheque/kabary/${k.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Implémenter le détail kabary (favori + partage + proverbes liés)**

`lib/features/bibliotheque/presentation/kabary_detail_page.dart` (remplacer le stub) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../favoris/data/favoris_repository.dart';
import '../../ohabolana/data/ohabolana_repository.dart';
import '../data/kabary_repository.dart';

class KabaryDetailPage extends ConsumerWidget {
  final String kabaryId;
  const KabaryDetailPage({super.key, required this.kabaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kabary = ref.watch(kabaryRepositoryProvider).getById(kabaryId);
    final favoris = ref.watch(favorisProvider);

    if (kabary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kabary introuvable')),
      );
    }

    final estFavori = favoris.kabary.contains(kabary.id);
    final ohabolanaRepo = ref.watch(ohabolanaRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(kabary.titre),
        actions: [
          IconButton(
            icon: Icon(estFavori ? Icons.star : Icons.star_outline),
            onPressed: () =>
                ref.read(favorisProvider.notifier).toggleKabary(kabary.id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final texte = kabary.sections
                  .map((s) => '${s.titre}\n${s.contenuMg}')
                  .join('\n\n');
              SharePlus.instance
                  .share(ShareParams(text: '${kabary.titre}\n\n$texte'));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${kabary.occasion} • ${kabary.region} • ${kabary.niveau}',
              style: Theme.of(context).textTheme.labelLarge),
          const Divider(height: 24),
          ...kabary.sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.titre,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(s.contenuMg,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(s.traductionFr,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          if (kabary.ohabolanaIds.isNotEmpty) ...[
            const Divider(),
            Text('Proverbes utilisés',
                style: Theme.of(context).textTheme.titleMedium),
            ...kabary.ohabolanaIds.map((id) {
              final o = ohabolanaRepo.getById(id);
              if (o == null) return const SizedBox.shrink();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o.texteMg),
                subtitle: Text(o.traductionFr),
                onTap: () => context.go('/ohabolana/${o.id}'),
              );
            }),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Vérifier analyse + tests**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter analyze && /home/happy/flutter/bin/flutter test
```
Expected: « No issues found! » et tous les tests PASS.

- [ ] **Step 4: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/bibliotheque/presentation
git commit -m "feat: liste Bibliothèque filtrable + détail kabary (favori, partage, proverbes liés)"
```

---

## Task 11: Page Ohabolana + détail

**Files:**
- Modify: `lib/features/ohabolana/presentation/ohabolana_page.dart`
- Modify: `lib/features/ohabolana/presentation/ohabolana_detail_page.dart`

- [ ] **Step 1: Implémenter la liste Ohabolana avec recherche**

`lib/features/ohabolana/presentation/ohabolana_page.dart` (remplacer le stub) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/ohabolana_repository.dart';

final rechercheProvider = StateProvider<String>((ref) => '');

class OhabolanaPage extends ConsumerWidget {
  const OhabolanaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(rechercheProvider);
    final resultats = ref.watch(ohabolanaRepositoryProvider).search(query);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un proverbe…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) =>
                ref.read(rechercheProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: resultats.length,
            itemBuilder: (context, i) {
              final o = resultats[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(o.texteMg),
                  subtitle: Text(o.traductionFr),
                  onTap: () => context.go('/ohabolana/${o.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Implémenter le détail ohabolana (favori)**

`lib/features/ohabolana/presentation/ohabolana_detail_page.dart` (remplacer le stub) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../favoris/data/favoris_repository.dart';
import '../data/ohabolana_repository.dart';

class OhabolanaDetailPage extends ConsumerWidget {
  final String ohabolanaId;
  const OhabolanaDetailPage({super.key, required this.ohabolanaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ohabolanaRepositoryProvider).getById(ohabolanaId);
    final favoris = ref.watch(favorisProvider);

    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Proverbe introuvable')),
      );
    }

    final estFavori = favoris.ohabolana.contains(o.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ohabolana'),
        actions: [
          IconButton(
            icon: Icon(estFavori ? Icons.star : Icons.star_outline),
            onPressed: () =>
                ref.read(favorisProvider.notifier).toggleOhabolana(o.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(o.texteMg, style: AppTheme.citation(context)),
          if (o.translitteration != null) ...[
            const SizedBox(height: 8),
            Text(o.translitteration!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ],
          const Divider(height: 24),
          _ligne(context, 'Traduction', o.traductionFr),
          if (o.signification != null)
            _ligne(context, 'Signification', o.signification!),
          if (o.usage != null) _ligne(context, 'Usage', o.usage!),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: o.themes
                .map((t) => Chip(label: Text(t)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _ligne(BuildContext context, String label, String valeur) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(valeur, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
}
```

- [ ] **Step 3: Vérifier analyse + tests**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter analyze && /home/happy/flutter/bin/flutter test
```
Expected: « No issues found! » et tous les tests PASS.

- [ ] **Step 4: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/ohabolana/presentation
git commit -m "feat: liste Ohabolana avec recherche + détail (favori)"
```

---

## Task 12: Page Favoris

**Files:**
- Modify: `lib/features/favoris/presentation/favoris_page.dart`

- [ ] **Step 1: Implémenter la page Favoris**

`lib/features/favoris/presentation/favoris_page.dart` (remplacer le stub) :
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../bibliotheque/data/kabary.dart';
import '../../bibliotheque/data/kabary_repository.dart';
import '../../ohabolana/data/ohabolana.dart';
import '../../ohabolana/data/ohabolana_repository.dart';
import '../data/favoris_repository.dart';

class FavorisPage extends ConsumerWidget {
  const FavorisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoris = ref.watch(favorisProvider);
    final kabaryRepo = ref.watch(kabaryRepositoryProvider);
    final ohabolanaRepo = ref.watch(ohabolanaRepositoryProvider);

    final kabaryFav = favoris.kabary
        .map(kabaryRepo.getById)
        .whereType<Kabary>()
        .toList();
    final ohabolanaFav = favoris.ohabolana
        .map(ohabolanaRepo.getById)
        .whereType<Ohabolana>()
        .toList();

    if (kabaryFav.isEmpty && ohabolanaFav.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucun favori pour le moment.\nTouchez ⭐ sur un kabary ou un proverbe.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (kabaryFav.isNotEmpty) ...[
          Text('Kabary', style: Theme.of(context).textTheme.titleLarge),
          ...kabaryFav.map(
            (k) => Card(
              child: ListTile(
                title: Text(k.titre),
                subtitle: Text('${k.occasion} • ${k.region}'),
                onTap: () => context.go('/bibliotheque/kabary/${k.id}'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (ohabolanaFav.isNotEmpty) ...[
          Text('Ohabolana', style: Theme.of(context).textTheme.titleLarge),
          ...ohabolanaFav.map(
            (o) => Card(
              child: ListTile(
                title: Text(o.texteMg),
                subtitle: Text(o.traductionFr),
                onTap: () => context.go('/ohabolana/${o.id}'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Vérifier analyse + tests**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter analyze && /home/happy/flutter/bin/flutter test
```
Expected: « No issues found! » et tous les tests PASS.

- [ ] **Step 3: Commit**

```bash
cd /home/happy/Documents/Joann/KbR
git add lib/features/favoris/presentation
git commit -m "feat: page Favoris (kabary + ohabolana regroupés)"
```

---

## Task 13: Build de l'APK et vérification finale

**Files:** aucun (build).

- [ ] **Step 1: Lancer toute la suite de tests**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter test
```
Expected: tous les tests PASS.

- [ ] **Step 2: Construire l'APK de debug**

Run:
```bash
cd /home/happy/Documents/Joann/KbR && /home/happy/flutter/bin/flutter build apk --debug
```
Expected: « Built build/app/outputs/flutter-apk/app-debug.apk ».

- [ ] **Step 3: Commit final (le cas échéant)**

Si des fichiers de configuration Android ont changé pendant le build :
```bash
cd /home/happy/Documents/Joann/KbR
git add -A
git commit -m "chore: premier build APK de debug Kabary"
```

---

## Notes d'exécution

- Le binaire Flutter est `/home/happy/flutter/bin/flutter` (pas forcément dans le PATH).
- Toutes les commandes de test/analyse/build doivent être lancées depuis `/home/happy/Documents/Joann/KbR`.
- **Convention de commit : ne jamais ajouter de ligne `Co-Authored-By` ni de mention de co-auteur** (cf. CLAUDE.md / mémoire projet).
- Le travail se fait sur la branche `kabary-mvp-local`.
```
