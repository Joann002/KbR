import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../bibliotheque/data/kabary_repository.dart';
import '../../ohabolana/data/ohabolana_repository.dart';

class AccueilPage extends ConsumerWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proverbe =
        ref.watch(ohabolanaRepositoryProvider).proverbeDuJour(DateTime.now());
    final kabaryRecents = ref.watch(kabaryRepositoryProvider).getAll();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kabary', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        Text('Ohabolana du jour',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proverbe.texteMg, style: AppTheme.citation(context)),
                const SizedBox(height: 8),
                Text(proverbe.traductionFr,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Kabary récents',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...kabaryRecents.map(
          (k) => Card(
            child: ListTile(
              title: Text(k.titre),
              subtitle: Text('${k.occasion} • ${k.region}'),
              onTap: () => context.go('/bibliotheque/kabary/${k.id}'),
            ),
          ),
        ),
      ],
    );
  }
}
