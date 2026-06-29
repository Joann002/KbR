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
