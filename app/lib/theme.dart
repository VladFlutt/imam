import 'package:flutter/material.dart';

/// Традиционная палитра: изумруд, золото, слоновая кость, ночное небо.
class Palette {
  static const emerald = Color(0xFF0F5E4A);
  static const pine = Color(0xFF0A3D31);
  static const gold = Color(0xFFC9A227);
  static const turquoise = Color(0xFF2A9D8F);
  static const ivory = Color(0xFFFAF6EC);
  static const parchment = Color(0xFFFFFDF7);
  static const ink = Color(0xFF1E2A27);
  static const night = Color(0xFF0B1A2B);
  static const dusk = Color(0xFF13263A);
}

String uiFont(String lang) => lang == 'ar' ? 'NotoNaskhArabic' : 'NotoSans';

ThemeData buildTheme({
  required bool dark,
  required String lang,
  required double scale,
}) {
  final scheme = dark
      ? const ColorScheme.dark(
          primary: Color(0xFF3FBF9B),
          onPrimary: Palette.night,
          secondary: Palette.gold,
          onSecondary: Palette.night,
          tertiary: Palette.turquoise,
          surface: Palette.dusk,
          onSurface: Color(0xFFEDE7D9),
          surfaceContainerHighest: Color(0xFF1B3149),
          outlineVariant: Color(0xFF2A4560),
        )
      : const ColorScheme.light(
          primary: Palette.emerald,
          onPrimary: Colors.white,
          secondary: Palette.gold,
          onSecondary: Palette.ink,
          tertiary: Palette.turquoise,
          surface: Palette.parchment,
          onSurface: Palette.ink,
          surfaceContainerHighest: Color(0xFFF1EBDC),
          outlineVariant: Color(0xFFE4DCC8),
        );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: uiFont(lang),
    fontFamilyFallback: const ['NotoSans', 'NotoNaskhArabic', 'Amiri'],
    scaffoldBackgroundColor: dark ? Palette.night : Palette.ivory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontSizeFactor: scale),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? Palette.night : Palette.ivory,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: 0.14),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: uiFont(lang), fontSize: 12),
      ),
    ),
  );
}

/// Стиль арабского текста Корана: крупный кегль и увеличенный интерлиньяж,
/// чтобы огласовки не наезжали на соседние строки.
TextStyle quranStyle(BuildContext context, {double size = 26}) => TextStyle(
  fontFamily: 'AmiriQuran',
  fontSize: size * MediaQuery.textScalerOf(context).scale(1),
  height: 2.1,
  color: Theme.of(context).colorScheme.onSurface,
);

TextStyle arabicStyle(BuildContext context, {double size = 20}) => TextStyle(
  fontFamily: 'Amiri',
  fontSize: size,
  height: 1.8,
  color: Theme.of(context).colorScheme.onSurface,
);
