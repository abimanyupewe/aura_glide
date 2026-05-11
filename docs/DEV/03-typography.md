# Typography - AuraGlide

Dokumen ini mendefinisikan tipografi yang digunakan dalam game AuraGlide.

## 1. Font Family

### Primary Font: Quicksand

Dipilih karena:
- **Sans-serif** dengan lekukan halus
- Bentuk karakter yang membulat dan friendly
- Easy to read di berbagai ukuran
- Terdapat di Google Fonts

### Fallback
```dart
fontFamily: 'Quicksand'
// Fallback: system default sans-serif
```

## 2. Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Light | 300 | Secondary text, hints |
| Regular | 400 | Body text, descriptions |
| Medium | 500 | Subtitles, labels |
| SemiBold | 600 | Important text, buttons |
| Bold | 700 | Headlines, scores |

## 3. Text Sizes

| Style | Size | Line Height | Letter Spacing |
|-------|------|-------------|----------------|
| Display Large | 48sp | 1.2 | -1.5 |
| Display Medium | 36sp | 1.2 | -0.5 |
| Headline Large | 28sp | 1.3 | 0 |
| Headline Medium | 24sp | 1.3 | 0 |
| Title Large | 20sp | 1.4 | 0.15 |
| Title Medium | 16sp | 1.4 | 0.15 |
| Body Large | 16sp | 1.5 | 0.5 |
| Body Medium | 14sp | 1.5 | 0.25 |
| Label Large | 14sp | 1.4 | 0.1 |
| Label Medium | 12sp | 1.4 | 0.5 |
| Label Small | 11sp | 1.4 | 0.5 |

## 4. Implementasi dalam Flutter

### app_typography.dart

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

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
}
```

### app_theme.dart

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.mintGreen,
        secondary: AppColors.babyBlue,
        surface: AppColors.background,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
    );
  }
}
```

## 5. Penggunaan dalam Widget

```dart
// Headline - untuk skor utama
Text(
  '1,250',
  style: Theme.of(context).textTheme.displayMedium,
)

// Title - untuk nama screen
Text(
  'AuraGlide',
  style: Theme.of(context).textTheme.headlineLarge,
)

// Body - untuk deskripsi
Text(
  'Match 3 blocks untuk skor!',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Label - untuk button
ElevatedButton(
  onPressed: () {},
  child: Text(
    'Play',
    style: Theme.of(context).textTheme.labelLarge,
  ),
)
```

## 6. Custom Text Styles (Game Specific)

```dart
// Score display with animation
class ScoreTextStyle {
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
```

## 7. Catatan Penting

- **Google Fonts** harus ditambahkan di `pubspec.yaml`
- Semua text styles menggunakan **Quicksand** secara konsisten
- **Warna teks** menggunakan `AppColors.textPrimary` bukan hitam murni
- Hindari hardcoded font sizes - gunakan yang sudah didefinisikan di TextTheme
- Untuk game elements (skor, floating text), bisa menggunakan custom TextStyle tambahan

---

**Referensi:**
- PRD Section 2: "Sans-serif yang membulat (Quicksand / Nunito) berwarna abu-abu lembut"
- Material Design 3 Typography Guidelines