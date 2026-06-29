import 'package:go_router/go_router.dart';
import '../../features/accueil/presentation/accueil_page.dart';
import '../../features/bibliotheque/presentation/bibliotheque_page.dart';
import '../../features/bibliotheque/presentation/kabary_detail_page.dart';
import '../../features/ohabolana/presentation/ohabolana_page.dart';
import '../../features/ohabolana/presentation/ohabolana_detail_page.dart';
import '../../features/favoris/presentation/favoris_page.dart';
import '../widgets/app_scaffold.dart';

/// Onglets de la barre de navigation, dans l'ordre.
const _tabs = ['/accueil', '/bibliotheque', '/ohabolana', '/favoris'];

int _indexForLocation(String location) {
  final i = _tabs.indexWhere((t) => location.startsWith(t));
  return i < 0 ? 0 : i;
}

final appRouter = GoRouter(
  initialLocation: '/accueil',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(
        currentIndex: _indexForLocation(state.uri.path),
        onTap: (i) => context.go(_tabs[i]),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/accueil',
          builder: (context, state) => const AccueilPage(),
        ),
        GoRoute(
          path: '/bibliotheque',
          builder: (context, state) => const BibliothequePage(),
          routes: [
            GoRoute(
              path: 'kabary/:id',
              builder: (context, state) =>
                  KabaryDetailPage(kabaryId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/ohabolana',
          builder: (context, state) => const OhabolanaPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  OhabolanaDetailPage(ohabolanaId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/favoris',
          builder: (context, state) => const FavorisPage(),
        ),
      ],
    ),
  ],
);
