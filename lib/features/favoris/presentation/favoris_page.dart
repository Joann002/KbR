import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../bibliotheque/data/kabary.dart';
import '../../bibliotheque/data/kabary_repository.dart';
import '../../ohabolana/data/ohabolana.dart';
import '../../ohabolana/data/ohabolana_repository.dart';
import '../data/favoris_repository.dart';

class FavorisPage extends ConsumerWidget {
  const FavorisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoris = ref.watch(favorisProvider);
    final kabaryRepo = ref.watch(kabaryRepositoryProvider);
    final ohabolanaRepo = ref.watch(ohabolanaRepositoryProvider);

    final kabaryFav = favoris.kabary
        .map(kabaryRepo.getById)
        .whereType<Kabary>()
        .toList();
    final ohabolanaFav = favoris.ohabolana
        .map(ohabolanaRepo.getById)
        .whereType<Ohabolana>()
        .toList();

    if (kabaryFav.isEmpty && ohabolanaFav.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucun favori pour le moment.\nTouchez ⭐ sur un kabary ou un proverbe.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (kabaryFav.isNotEmpty) ...[
          Text('Kabary', style: Theme.of(context).textTheme.titleLarge),
          ...kabaryFav.map(
            (k) => Card(
              child: ListTile(
                title: Text(k.titre),
                subtitle: Text('${k.occasion} • ${k.region}'),
                onTap: () => context.go('/bibliotheque/kabary/${k.id}'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (ohabolanaFav.isNotEmpty) ...[
          Text('Ohabolana', style: Theme.of(context).textTheme.titleLarge),
          ...ohabolanaFav.map(
            (o) => Card(
              child: ListTile(
                title: Text(o.texteMg),
                subtitle: Text(o.traductionFr),
                onTap: () => context.go('/ohabolana/${o.id}'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
