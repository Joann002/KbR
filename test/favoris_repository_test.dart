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
