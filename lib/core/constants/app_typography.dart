import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.quicksand(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.quicksand(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      ),
    );
  }

  static const TextStyle scoreDisplay = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
  );

  static const TextStyle floatingScore = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.accentPositive,
    letterSpacing: 0,
  );

  static const TextStyle multiplier = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.accentWarning,
  );
}