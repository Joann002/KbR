import 'package:flutter/material.dart';

/// Coquille hébergeant les 4 onglets et la barre de navigation basse.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Bibliothèque'),
          NavigationDestination(icon: Icon(Icons.spa_outlined), label: 'Ohabolana'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'Favoris'),
        ],
      ),
    );
  }
}
