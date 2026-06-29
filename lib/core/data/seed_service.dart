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
