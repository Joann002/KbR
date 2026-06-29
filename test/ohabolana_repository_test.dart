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
