import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../favoris/data/favoris_repository.dart';
import '../../ohabolana/data/ohabolana_repository.dart';
import '../data/kabary_repository.dart';

class KabaryDetailPage extends ConsumerWidget {
  final String kabaryId;
  const KabaryDetailPage({super.key, required this.kabaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kabary = ref.watch(kabaryRepositoryProvider).getById(kabaryId);
    final favoris = ref.watch(favorisProvider);

    if (kabary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kabary introuvable')),
      );
    }

    final estFavori = favoris.kabary.contains(kabary.id);
    final ohabolanaRepo = ref.watch(ohabolanaRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(kabary.titre),
        actions: [
          IconButton(
            icon: Icon(estFavori ? Icons.star : Icons.star_outline),
            onPressed: () =>
                ref.read(favorisProvider.notifier).toggleKabary(kabary.id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final texte = kabary.sections
                  .map((s) => '${s.titre}\n${s.contenuMg}')
                  .join('\n\n');
              SharePlus.instance
                  .share(ShareParams(text: '${kabary.titre}\n\n$texte'));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${kabary.occasion} • ${kabary.region} • ${kabary.niveau}',
              style: Theme.of(context).textTheme.labelLarge),
          const Divider(height: 24),
          ...kabary.sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.titre,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(s.contenuMg,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(s.traductionFr,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          if (kabary.ohabolanaIds.isNotEmpty) ...[
            const Divider(),
            Text('Proverbes utilisés',
                style: Theme.of(context).textTheme.titleMedium),
            ...kabary.ohabolanaIds.map((id) {
              final o = ohabolanaRepo.getById(id);
              if (o == null) return const SizedBox.shrink();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o.texteMg),
                subtitle: Text(o.traductionFr),
                onTap: () => context.go('/ohabolana/${o.id}'),
              );
            }),
          ],
        ],
      ),
    );
  }
}
