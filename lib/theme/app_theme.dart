import 'package:flutter/material.dart';

/// The "Qamar" (moon) design language: soft, calm, paper-and-ink,
/// generous whitespace, dynamic accent. This file defines the light and
/// dark variants; the "auto" prayer-time-driven accent (FR-65) hooks in
/// via [qamarAccentForPrayer].
class AppTheme {
  const AppTheme._();

  static const _seed = Color(0xFF2E6F5E); // deep teal-green, calm & neutral

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: scheme.surfaceContainerHigh,
      ),
      textTheme: const TextTheme().apply(
        fontSizeFactor: 1.0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }

  /// Prayer-time-driven accent hue for the "Qamar auto" theme variant
  /// (FR-65) — subtle shifts, not jarring: cool blue pre-dawn, warm gold
  /// at Maghrib, deep indigo at night.
  static Color qamarAccentForPrayer(String prayerName) {
    switch (prayerName) {
      case 'fajr':
        return const Color(0xFF4A6FA5);
      case 'sunrise':
        return const Color(0xFFE0A85C);
      case 'dhuhr':
        return const Color(0xFF2E6F5E);
      case 'asr':
        return const Color(0xFFC97B4A);
      case 'maghrib':
        return const Color(0xFFB5563C);
      case 'isha':
        return const Color(0xFF34335C);
      default:
        return _seed;
    }
  }
}
