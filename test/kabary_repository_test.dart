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
