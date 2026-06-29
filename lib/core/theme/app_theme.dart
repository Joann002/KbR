import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Thèmes de l'application Kabary.
class AppTheme {
  AppTheme._();

  static ThemeData get clair {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.fondClair,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaire,
        primary: AppColors.primaire,
        secondary: AppColors.secondaire,
        tertiary: AppColors.accent,
        surface: AppColors.fondClair,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(textTheme: _textTheme(base.textTheme, AppColors.texte));
  }

  static ThemeData get sombre {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.fondSombre,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaire,
        primary: AppColors.primaire,
        secondary: AppColors.secondaire,
        tertiary: AppColors.accent,
        surface: AppColors.fondSombre,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme, const Color(0xFFFAF7F0)),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color couleurTexte) {
    final corps = GoogleFonts.notoSansTextTheme(base).apply(
      bodyColor: couleurTexte,
      displayColor: couleurTexte,
    );
    return corps.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(textStyle: corps.displayLarge),
      displayMedium: GoogleFonts.playfairDisplay(textStyle: corps.displayMedium),
      displaySmall: GoogleFonts.playfairDisplay(textStyle: corps.displaySmall),
      headlineLarge: GoogleFonts.playfairDisplay(textStyle: corps.headlineLarge),
      headlineMedium: GoogleFonts.playfairDisplay(textStyle: corps.headlineMedium),
      headlineSmall: GoogleFonts.playfairDisplay(textStyle: corps.headlineSmall),
      titleLarge: GoogleFonts.playfairDisplay(textStyle: corps.titleLarge),
    );
  }

  /// Style dédié aux citations / proverbes (Cormorant Garamond, italique).
  static TextStyle citation(BuildContext context) => GoogleFonts.cormorantGaramond(
        textStyle: Theme.of(context).textTheme.titleLarge,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
      );
}
