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
