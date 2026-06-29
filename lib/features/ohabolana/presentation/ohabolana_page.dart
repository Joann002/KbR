import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/ohabolana_repository.dart';

/// Texte de recherche courant. Riverpod 3.x : Notifier (StateProvider déprécié).
class Recherche extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final rechercheProvider =
    NotifierProvider<Recherche, String>(Recherche.new);

class OhabolanaPage extends ConsumerWidget {
  const OhabolanaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(rechercheProvider);
    final resultats = ref.watch(ohabolanaRepositoryProvider).search(query);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un proverbe…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) =>
                ref.read(rechercheProvider.notifier).set(v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: resultats.length,
            itemBuilder: (context, i) {
              final o = resultats[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(o.texteMg),
                  subtitle: Text(o.traductionFr),
                  onTap: () => context.go('/ohabolana/${o.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
