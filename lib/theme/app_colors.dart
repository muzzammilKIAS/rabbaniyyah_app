import 'package:flutter/material.dart';

/// "Emerald Rabbani & Royal Gold" — an inspiring, serene Islamic academic
/// palette designed for modern educational web & mobile apps.
/// Features deep forest emerald (#065F46) as primary, vibrant amber gold (#D97706)
/// as royal accent, alongside clean warm surfaces and crisp typography.
class AppColors {
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color accentStrong;
  final Color accentSoft;
  final Color accent2;
  final Color accent2Soft;
  final Color border;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color gold;
  final Color goldSoft;
  final Color goldBorder;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color cardShadow;

  const AppColors({
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.accent2,
    required this.accent2Soft,
    required this.border,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.gold,
    required this.goldSoft,
    required this.goldBorder,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.cardShadow,
  });

  static const light = AppColors(
    gradientStart: Color(0xFFEFF8F3),
    gradientMiddle: Color(0xFFF7FAF8),
    gradientEnd: Color(0xFFF1F5F2),
    bg: Color(0xFFF4F7F5),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEDF4F0),
    text: Color(0xFF0F172A),
    textMuted: Color(0xFF475569),
    accent: Color(0xFF065F46),
    accentStrong: Color(0xFF047857),
    accentSoft: Color(0xFFD1FAE5),
    accent2: Color(0xFFD97706),
    accent2Soft: Color(0xFFFEF3C7),
    border: Color(0xFFE2E8F0),
    success: Color(0xFF059669),
    successSoft: Color(0xFFD1FAE5),
    danger: Color(0xFFE11D48),
    dangerSoft: Color(0xFFFFE4E6),
    gold: Color(0xFFD97706),
    goldSoft: Color(0xFFFEF3C7),
    goldBorder: Color(0xFFFDE68A),
    heroGradientStart: Color(0xFF064E3B),
    heroGradientEnd: Color(0xFF047857),
    cardShadow: Color(0x0C0F172A),
  );

  static const dark = AppColors(
    gradientStart: Color(0xFF06140E),
    gradientMiddle: Color(0xFF091B13),
    gradientEnd: Color(0xFF0D241A),
    bg: Color(0xFF07140E),
    surface: Color(0xFF0F261C),
    surface2: Color(0xFF163527),
    text: Color(0xFFF1F5F9),
    textMuted: Color(0xFF94A3B8),
    accent: Color(0xFF10B981),
    accentStrong: Color(0xFF34D399),
    accentSoft: Color(0xFF134231),
    accent2: Color(0xFFF59E0B),
    accent2Soft: Color(0xFF3B2E15),
    border: Color(0xFF1B3D2E),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF134231),
    danger: Color(0xFFFB7185),
    dangerSoft: Color(0xFF4C1D24),
    gold: Color(0xFFFBBF24),
    goldSoft: Color(0xFF3B2E15),
    goldBorder: Color(0xFF785418),
    heroGradientStart: Color(0xFF072115),
    heroGradientEnd: Color(0xFF0D3624),
    cardShadow: Color(0x35000000),
  );
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final AppColors colors;
  const AppColorsExtension(this.colors);

  @override
  AppColorsExtension copyWith({AppColors? colors}) =>
      AppColorsExtension(colors ?? this.colors);

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return t < 0.5 ? this : other;
  }
}

extension BuildContextColors on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColorsExtension>()!.colors;
}
