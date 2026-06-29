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
