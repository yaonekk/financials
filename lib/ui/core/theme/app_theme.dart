import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand & Accents
  static const Color primary = Color(0xFF1E40AF); // Deep Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Sky Blue
  static const Color primarySoft = Color(0xFF1D4ED8);

  // Semantics
  static const Color income = Color(0xFF059669); // Emerald Green
  static const Color incomeSoft = Color(0xFF064E3B);
  static const Color expense = Color(0xFFDC2626); // Red
  static const Color expenseSoft = Color(0xFF7F1D1D);
  static const Color warning = Color(0xFFF59E0B); // Amber

  // Dark Slate Palette (Premium Fintech)
  static const Color bgDark = Color(0xFF0F172A); // Deep Midnight
  static const Color surfaceDark = Color(0xFF111827); // Charcoal
  static const Color cardDark = Color(0xFF192134); // Elevated surface
  static const Color cardBorderDark = Color(0xFF1E2D4A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Light Palette
  static const Color bgLight = Color(0xFFF1F5F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.ibmPlexSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w800, letterSpacing: -1.5),
      displayMedium: base.displayMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w700, letterSpacing: -1.0),
      displaySmall: base.displaySmall?.copyWith(color: primaryText, fontWeight: FontWeight.w700),
      headlineLarge: base.headlineLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: base.headlineMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: base.titleMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(color: secondaryText, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: primaryText),
      bodyMedium: base.bodyMedium?.copyWith(color: secondaryText),
      bodySmall: base.bodySmall?.copyWith(color: secondaryText),
      labelLarge: base.labelLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: secondaryText, fontWeight: FontWeight.w500),
      labelSmall: base.labelSmall?.copyWith(color: secondaryText, letterSpacing: 0.8),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.income,
        error: AppColors.expense,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorderDark, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardDark,
        contentTextStyle: GoogleFonts.ibmPlexSans(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorderDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(color: AppColors.textSecondaryDark),
        hintStyle: GoogleFonts.ibmPlexSans(color: AppColors.textMutedDark),
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.income,
        error: AppColors.expense,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorderLight, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        contentTextStyle: GoogleFonts.ibmPlexSans(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(color: AppColors.textSecondaryLight),
        hintStyle: GoogleFonts.ibmPlexSans(color: AppColors.textMutedLight),
      ),
    );
  }
}
