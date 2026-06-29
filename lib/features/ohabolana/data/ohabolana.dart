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
