import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFAF9F6);
  static const Color backgroundSecondary = Color(0xFFF5F4F1);

  static const Color mintGreen = Color(0xFFA8E6CF);
  static const Color babyBlue = Color(0xFFA8D8EA);
  static const Color softPeach = Color(0xFFFFD3B6);
  static const Color lilac = Color(0xFFD4A5FF);
  static const Color lavender = Color(0xFFE0BBE4);
  static const Color softYellow = Color(0xFFFFE5B4);

  static const Color textPrimary = Color(0xFF6B7280);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFFD1D5DB);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color accentPositive = Color(0xFF10B981);
  static const Color accentWarning = Color(0xFFF59E0B);
  static const Color accentNeutral = Color(0xFFE5E7EB);

  static const Color blockHighlight = Color(0x4DFFFFFF);
  static const Color blockShadow = Color(0x14000000);
  static const Color matchFlash = Color(0x80FFFFFF);

  static const List<Color> blockColors = [
    mintGreen,
    babyBlue,
    softPeach,
    lilac,
    lavender,
    softYellow,
  ];

  static Color getBlockColor(int index) {
    return blockColors[index % blockColors.length];
  }
}