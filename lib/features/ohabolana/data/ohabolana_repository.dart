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
