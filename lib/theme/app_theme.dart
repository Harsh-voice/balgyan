import 'package:flutter/material.dart';

/// BalGyan design tokens — professional claymorphism for a kids-education
/// brand: learning blue + play amber + fun pink on an ice-blue canvas,
/// soft inflated surfaces, and zero emoji (typographic marks + drawn icons).
abstract final class AppColors {
  static const primary = Color(0xFF2563EB); // learning blue
  static const primaryDeep = Color(0xFF1D4ED8);
  static const amber = Color(0xFFF59E0B); // play
  static const pink = Color(0xFFEC4899); // fun
  static const violet = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const sky = Color(0xFF0EA5E9);

  static const background = Color(0xFFEFF6FF); // ice blue canvas
  static const surface = Colors.white;
  static const ink = Color(0xFF0F172A); // slate ink
  static const inkSoft = Color(0xFF64748B);
  static const border = Color(0xFFE4ECFC);
  static const muted = Color(0xFFF1F5FD);
  static const locked = Color(0xFFE2E8F0);
  static const lockedInk = Color(0xFF94A3B8);

  /// Soft pastel washes behind lesson pages, one per accent.
  static const tints = [
    Color(0xFFDBEAFE), // blue
    Color(0xFFFEF3C7), // amber
    Color(0xFFFCE7F3), // pink
    Color(0xFFEDE9FE), // violet
    Color(0xFFD1FAE5), // green
    Color(0xFFE0F2FE), // sky
  ];

  /// Saturated accent matching each tint index (for progress bars, chips).
  static const accents = [primary, amber, pink, violet, green, sky];
}

abstract final class AppShapes {
  static const radiusCard = 32.0;
  static const radiusButton = 24.0;

  /// Colored clay: vertical light-to-base gradient, faint white rim, and a
  /// tinted drop shadow — reads as a soft inflated object.
  static BoxDecoration clay(Color base, {double radius = radiusButton}) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(base, Colors.white, 0.22)!, base],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.40),
            offset: const Offset(0, 10),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      );

  /// White clay card on the ice-blue canvas.
  static BoxDecoration surfaceClay({double radius = radiusCard}) =>
      BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.07),
            offset: const Offset(0, 12),
            blurRadius: 24,
            spreadRadius: -6,
          ),
        ],
      );

  /// Flat inset look for locked / disabled surfaces — deliberately not clay.
  static BoxDecoration flat({double radius = radiusCard}) => BoxDecoration(
        color: AppColors.locked,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      );
}

abstract final class AppText {
  static const _family = 'Baloo2';

  // Variable font: FontWeight alone doesn't move the wght axis on all
  // engines, so every style pins it explicitly via fontVariations.
  static TextStyle _base(double size, double wght,
          [Color color = AppColors.ink]) =>
      TextStyle(
        fontFamily: _family,
        fontSize: size,
        color: color,
        fontWeight: FontWeight.lerp(
            FontWeight.w100, FontWeight.w900, (wght - 100) / 800),
        fontVariations: [FontVariation('wght', wght)],
        height: 1.15,
      );

  static TextStyle display(double size, [Color color = AppColors.ink]) =>
      _base(size, 700, color);
  static TextStyle title = _base(24, 700);
  static TextStyle body = _base(17, 500);
  static TextStyle label(Color color) => _base(15, 600, color);
  static TextStyle caption = _base(13, 500, AppColors.inkSoft);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    surface: AppColors.background,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Baloo2',
    textTheme: Typography.blackMountainView.apply(
      fontFamily: 'Baloo2',
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppText.title,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
