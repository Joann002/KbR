import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kabary/core/data/providers.dart';
import 'package:kabary/features/accueil/presentation/accueil_page.dart';
import 'package:kabary/features/ohabolana/data/ohabolana.dart';

void main() {
  late Directory tempDir;
  late Box ohabolanaBox;
  late Box kabaryBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('accueil_test');
    Hive.init(tempDir.path);
    ohabolanaBox = await Hive.openBox('ohabolana');
    kabaryBox = await Hive.openBox('kabary');
    const o = Ohabolana(
      id: 'o1',
      texteMg: 'Ny fihavanana no tsy mba azo vidina vola.',
      traductionFr: 'La solidarité ne s\'achète pas.',
      themes: ['fihavanana'],
    );
    await ohabolanaBox.put(o.id, jsonEncode(o.toJson()));
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('affiche le proverbe du jour', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ohabolanaBoxProvider.overrideWithValue(ohabolanaBox),
          kabaryBoxProvider.overrideWithValue(kabaryBox),
        ],
        child: const MaterialApp(home: Scaffold(body: AccueilPage())),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Ohabolana du jour'), findsOneWidget);
    expect(
      find.textContaining('Ny fihavanana no tsy mba azo vidina vola.'),
      findsOneWidget,
    );
  });
}
