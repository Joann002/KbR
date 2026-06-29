import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/kabary_repository.dart';

/// État du filtre d'occasion sélectionné (null = toutes).
/// Riverpod 3.x : on utilise un Notifier (StateProvider est déprécié).
class OccasionFiltre extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? occasion) => state = occasion;
}

final occasionFiltreProvider =
    NotifierProvider<OccasionFiltre, String?>(OccasionFiltre.new);

class BibliothequePage extends ConsumerWidget {
  const BibliothequePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(kabaryRepositoryProvider);
    final occasion = ref.watch(occasionFiltreProvider);
    final kabary = repo.filter(occasion: occasion);

    final occasions =
        repo.getAll().map((k) => k.occasion).toSet().toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Bibliothèque',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Toutes'),
                  selected: occasion == null,
                  onSelected: (_) =>
                      ref.read(occasionFiltreProvider.notifier).set(null),
                ),
              ),
              ...occasions.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: occasion == o,
                    onSelected: (_) =>
                        ref.read(occasionFiltreProvider.notifier).set(o),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: kabary.length,
            itemBuilder: (context, i) {
              final k = kabary[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(k.titre),
                  subtitle: Text(
                      '${k.occasion} • ${k.region} • ${k.niveau} • ~${k.dureeMinutes} min'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/bibliotheque/kabary/${k.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
