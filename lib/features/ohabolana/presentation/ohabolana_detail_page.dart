import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../favoris/data/favoris_repository.dart';
import '../data/ohabolana_repository.dart';

class OhabolanaDetailPage extends ConsumerWidget {
  final String ohabolanaId;
  const OhabolanaDetailPage({super.key, required this.ohabolanaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(ohabolanaRepositoryProvider).getById(ohabolanaId);
    final favoris = ref.watch(favorisProvider);

    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Proverbe introuvable')),
      );
    }

    final estFavori = favoris.ohabolana.contains(o.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ohabolana'),
        actions: [
          IconButton(
            icon: Icon(estFavori ? Icons.star : Icons.star_outline),
            onPressed: () =>
                ref.read(favorisProvider.notifier).toggleOhabolana(o.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(o.texteMg, style: AppTheme.citation(context)),
          if (o.translitteration != null) ...[
            const SizedBox(height: 8),
            Text(o.translitteration!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ],
          const Divider(height: 24),
          _ligne(context, 'Traduction', o.traductionFr),
          if (o.signification != null)
            _ligne(context, 'Signification', o.signification!),
          if (o.usage != null) _ligne(context, 'Usage', o.usage!),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: o.themes
                .map((t) => Chip(label: Text(t)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _ligne(BuildContext context, String label, String valeur) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(valeur, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
}
