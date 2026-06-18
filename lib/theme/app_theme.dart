import 'package:flutter/material.dart';

/// Centralized design system for Journal Trend Analyzer.
///
/// One source of truth for colors, spacing, radii, shadows, gradients and the
/// global [ThemeData] so every screen looks consistent and professional.
class AppColors {
  AppColors._();

  // Brand — rose / pink family
  static const Color primary = Color(0xFFDB2777); // pink-600
  static const Color primaryBright = Color(0xFFEC4899); // pink-500
  static const Color primarySoft = Color(0xFFFCE7F3); // pink-100

  // Text
  static const Color ink = Color(0xFF111827); // headings
  static const Color body = Color(0xFF374151); // body text
  static const Color muted = Color(0xFF6B7280); // secondary
  static const Color faint = Color(0xFF9CA3AF); // tertiary / hints

  // Surfaces
  static const Color background = Color(0xFFF7F8FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDEFF3);

  // Accents (KPIs, charts, badges)
  static const Color indigo = Color(0xFF6366F1);
  static const Color amber = Color(0xFFF59E0B);
  static const Color emerald = Color(0xFF10B981);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color danger = Color(0xFFEF4444);

  // Medal colors
  static const Color gold = Color(0xFFF5B301);
  static const Color silver = Color(0xFF9AA7B8);
  static const Color bronze = Color(0xFFCD7F45);
}

class AppGradients {
  AppGradients._();

  /// Primary brand gradient used for headers and hero surfaces.
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
}

class AppShadows {
  AppShadows._();

  /// Soft, modern elevation for cards.
  static List<BoxShadow> get soft => const [
        BoxShadow(
          color: Color(0x0F101828),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

  /// Slightly stronger shadow tinted with the brand color.
  static List<BoxShadow> brand({double opacity = 0.30}) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: opacity),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Reusable decoration helpers.
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card({double radius = AppRadius.lg, Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.soft,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.card,
    );

    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.body,
      displayColor: AppColors.ink,
    ).copyWith(
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.5,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.3,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: AppColors.body,
        height: 1.45,
      ),
      bodySmall: const TextStyle(
        fontSize: 12.5,
        color: AppColors.muted,
      ),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.faint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}
