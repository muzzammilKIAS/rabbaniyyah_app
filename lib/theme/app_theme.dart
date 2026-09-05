import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// Kandungan silibus sebenar — teks bacaan, kosa kata, kaedah nahu,
  /// petikan latihan, semakan objektif pembelajaran (Amiri Naskh rasmi).
  static const arabicFont = 'Amiri';
  static const quranFont = 'AmiriQuran';

  /// Tajuk, kotak/kad, butang, lencana, rel navigasi, dan elemen UI utama (Tajawal).
  static const uiFont = 'Tajawal';
  static const headingFont = 'Tajawal';

  /// Arahan latihan, panduan, petunjuk teks, dan nota bimbingan (Amiri).
  static const instructionFont = 'Amiri';

  static ThemeData _build(AppColors c, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: c.bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        surface: c.surface,
        primary: c.accent,
        secondary: c.accent2,
        error: c.danger,
        onSurface: c.text,
        onPrimary: c.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        foregroundColor: c.text,
        titleTextStyle: const TextStyle(
          fontFamily: headingFont,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      cardColor: c.surface,
      dividerColor: c.border,
      // Tipografi rasmi mengikut hierarki:
      // - Tajawal: tajuk, kotak/kad, butang, navigasi & elemen UI utama.
      // - Amiri: arahan latihan, panduan, bimbingan serta semua kandungan silibus & pembelajaran.
      textTheme: base.textTheme.apply(
        bodyColor: c.text,
        displayColor: c.text,
        fontFamily: uiFont,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.accent;
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: c.border, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: c.accent.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: instructionFont,
          fontSize: 15,
          color: c.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.accent, width: 1.8),
        ),
      ),
      extensions: [AppColorsExtension(c)],
    );
  }

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);
}
