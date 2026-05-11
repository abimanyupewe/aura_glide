# Palette Warna - AuraGlide

Dokumen ini mendefinisikan semua warna yang digunakan dalam game AuraGlide berdasarkan prinsip **Intentional Minimalism**.

## 1. Warna Utama (Main Colors)

### Background
| Nama | Hex Code | Usage |
|------|----------|-------|
| Background | `#FAF9F6` | Latar belakang layar game |
| Background Secondary | `#F5F4F1` | Card overlay, dialog |

### Block Colors (Pastel Palette)
| Nama | Hex Code | Usage |
|------|----------|-------|
| Mint Green | `#A8E6CF` | Block type 1 |
| Baby Blue | `#A8D8EA` | Block type 2 |
| Soft Peach | `#FFD3B6` | Block type 3 |
| Lilac | `#D4A5FF` | Block type 4 |
| Lavender | `#E0BBE4` | Block type 5 (opsional) |
| Soft Yellow | `#FFE5B4` | Block type 6 (opsional) |

## 2. Warna Teks (Typography Colors)

| Nama | Hex Code | Usage |
|------|----------|-------|
| Text Primary | `#6B7280` | Judul, skor utama |
| Text Secondary | `#9CA3AF` | Subtitle, deskripsi |
| Text Tertiary | `#D1D5DB` | Placeholder, disabled |
| Text On Dark | `#FFFFFF` | Teks di atas background gelap |

## 3. Warna Accent (UI Accents)

| Nama | Hex Code | Usage |
|------|----------|-------|
| Accent Positive | `#10B981` | Match success, +score |
| Accent Warning | `#F59E0B` | Cascade multiplier |
| Accent Neutral | `#E5E7EB` | Divider, border subtle |

## 4. Warna Animasi (Animation States)

| Nama | Hex Code | Usage |
|------|----------|-------|
| Block Highlight | `#FFFFFF` (opacity 0.3) | Selection glow |
| Block Shadow | `#000000` (opacity 0.08) | Drop shadow subtle |
| Match Flash | `#FFFFFF` (opacity 0.5) | Flash saat match |

## 5. Implementasi dalam Flutter

### app_colors.dart

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFFFAF9F6);
  static const Color backgroundSecondary = Color(0xFFF5F4F1);

  // Blocks
  static const Color mintGreen = Color(0xFFA8E6CF);
  static const Color babyBlue = Color(0xFFA8D8EA);
  static const Color softPeach = Color(0xFFFFD3B6);
  static const Color lilac = Color(0xFFD4A5FF);
  static const Color lavender = Color(0xFFE0BBE4);
  static const Color softYellow = Color(0xFFFFE5B4);

  // Text
  static const Color textPrimary = Color(0xFF6B7280);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFFD1D5DB);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Accent
  static const Color accentPositive = Color(0xFF10B981);
  static const Color accentWarning = Color(0xFFF59E0B);
  static const Color accentNeutral = Color(0xFFE5E7EB);

  // Animation
  static const Color blockHighlight = Color(0x4DFFFFFF);
  static const Color blockShadow = Color(0x14000000);
  static const Color matchFlash = Color(0x80FFFFFF);

  // Block Color List (untuk indexing)
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
```

### Usage Example

```dart
Container(
  color: AppColors.mintGreen,
  child: Text(
    'Score: 100',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)

// Atau menggunakan block color berdasarkan index
Color blockColor = AppColors.getBlockColor(blockType);
```

## 6. Catatan Desain

- **Tidak ada border** pada block - menggunakan rounded corners (borderRadius)
- **Tidak ada shadow kasar** - hanya opacity sangat rendah untuk depth subtil
- **Warna pastel** dipilih untuk menjaga vibe tenang dan tidak mencolok
- **Kontras rendah** antara background dan block untuk reduce visual strain
- **Hex colors** menggunakan format lowercase tanpa prefix `#`

---

**Referensi:** Lihat PRD Section 2 untuk filosofi desain lengkap.