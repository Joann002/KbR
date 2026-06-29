import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/data/providers.dart';
import 'core/data/seed_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final kabaryBox = await Hive.openBox('kabary');
  final ohabolanaBox = await Hive.openBox('ohabolana');
  final favorisBox = await Hive.openBox('favoris');
  final metaBox = await Hive.openBox('meta');

  await SeedService(
    kabaryBox: kabaryBox,
    ohabolanaBox: ohabolanaBox,
    metaBox: metaBox,
    readAsset: rootBundle.loadString,
  ).seedIfNeeded();

  runApp(
    ProviderScope(
      overrides: [
        kabaryBoxProvider.overrideWithValue(kabaryBox),
        ohabolanaBoxProvider.overrideWithValue(ohabolanaBox),
        favorisBoxProvider.overrideWithValue(favorisBox),
      ],
      child: const KabaryApp(),
    ),
  );
}

class KabaryApp extends StatelessWidget {
  const KabaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kabary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair,
      darkTheme: AppTheme.sombre,
      routerConfig: appRouter,
    );
  }
}
