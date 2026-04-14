import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A0E8F);
  static const Color primaryLight = Color(0xFF7B2FBE);
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentGlow = Color(0xFF00B8D9);
  static const Color bgDark = Color(0xFF0A0A1A);
  static const Color bgCard = Color(0xFF12122A);
  static const Color bgCardLight = Color(0xFF1A1A35);
  static const Color surface = Color(0xFF16163A);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9090B8);
  static const Color textHint = Color(0xFF5A5A80);
  static const Color divider = Color(0xFF2A2A50);
  static const Color error = Color(0xFFFF4B6E);
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFB74D);

  // ── Light mode equivalents ──────────────────────────────────────────
  static const Color lightBg = Color(0xFFF2F0FF);
  static const Color lightBgCard = Color(0xFFFFFFFF);
  static const Color lightBgCardLight = Color(0xFFEDE8FF);
  static const Color lightSurface = Color(0xFFE8E4FF);
  static const Color lightTextPrimary = Color(0xFF1A1A35);
  static const Color lightTextSecondary = Color(0xFF4A4A70);
  static const Color lightTextHint = Color(0xFF9090B8);
  static const Color lightDivider = Color(0xFFD0C8F0);
  static const Color lightAccent = Color(0xFF00B8D9);

  static const List<Color> tagColors = [
    Color(0xFF7B2FBE),
    Color(0xFF00B8D9),
    Color(0xFFFF4B6E),
    Color(0xFF00E5A0),
    Color(0xFFFFB74D),
    Color(0xFFE040FB),
    Color(0xFF69F0AE),
    Color(0xFFFF6D00),
  ];
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      extensions: const [AppColorScheme.dark()],
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCardLight,
        selectedColor: AppColors.primary.withOpacity(0.4),
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.accent : AppColors.textHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.accent.withOpacity(0.3)
            : AppColors.divider),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      extensions: const [AppColorScheme.light()],
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextHint),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBgCardLight,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.lightAccent : AppColors.lightTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.lightAccent.withOpacity(0.3)
            : AppColors.lightDivider),
      ),
    );
  }
}

// ── Theme extension so widgets can read the correct colors at runtime ──
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color bgCard;
  final Color bgCardLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color accent;

  const AppColorScheme({
    required this.bgCard,
    required this.bgCardLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.accent,
  });

  const AppColorScheme.dark()
      : bgCard = AppColors.bgCard,
        bgCardLight = AppColors.bgCardLight,
        textPrimary = AppColors.textPrimary,
        textSecondary = AppColors.textSecondary,
        textHint = AppColors.textHint,
        divider = AppColors.divider,
        accent = AppColors.accent;

  const AppColorScheme.light()
      : bgCard = AppColors.lightBgCard,
        bgCardLight = AppColors.lightBgCardLight,
        textPrimary = AppColors.lightTextPrimary,
        textSecondary = AppColors.lightTextSecondary,
        textHint = AppColors.lightTextHint,
        divider = AppColors.lightDivider,
        accent = AppColors.lightAccent;

  @override
  AppColorScheme copyWith({
    Color? bgCard,
    Color? bgCardLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? accent,
  }) {
    return AppColorScheme(
      bgCard: bgCard ?? this.bgCard,
      bgCardLight: bgCardLight ?? this.bgCardLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardLight: Color.lerp(bgCardLight, other.bgCardLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

class AppStrings {
  static const String appName = 'PsyNoteX';
  static const String tagline = 'Capture thoughts. Understand moods.';
  static const String devName = 'Div Api';
  static const String devEmail = 'aqsa.tips@gmail.com';
  static const String appDesc =
      'PsyNoteX helps you capture thoughts instantly and understand your mood patterns.';
  static const String version = '1.0.0';
}