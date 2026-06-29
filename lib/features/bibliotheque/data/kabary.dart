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
