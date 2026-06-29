import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Boxes Hive. Surchargés dans main() avec les boxes réellement ouvertes.
final kabaryBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('kabaryBoxProvider doit être surchargé'),
);
final ohabolanaBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('ohabolanaBoxProvider doit être surchargé'),
);
final favorisBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError('favorisBoxProvider doit être surchargé'),
);
