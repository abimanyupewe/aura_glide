# Setup Project & Dependencies

## 1. Inisialisasi Project Flutter

```bash
cd /home/clara/Project/FLutter/aura_glide
flutter create aura_glide --org com.aura --platforms android,ios
cd aura_glide
```

## 2. Dependencies (pubspec.yaml)

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI/Animations
  google_fonts: ^6.1.0

  # Utilities
  equatable: ^2.0.5
  uuid: ^4.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  hive_generator: ^2.0.1

  # Linting
  flutter_lints: ^3.0.1
```

### Install Dependencies
```bash
flutter pub get
```

## 3. Folder Structure (Clean Architecture)

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_dimensions.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── extensions.dart
├── domain/
│   ├── entities/
│   │   ├── block.dart
│   │   ├── grid.dart
│   │   └── game_state.dart
│   ├── repositories/
│   │   └── score_repository.dart
│   └── usecases/
│       ├── swap_blocks.dart
│       ├── detect_matches.dart
│       ├── apply_gravity.dart
│       └── calculate_score.dart
├── data/
│   ├── repositories/
│   │   └── score_repository_impl.dart
│   ├── datasources/
│   │   └── local_storage.dart
│   └── models/
│       └── game_state_model.dart
├── presentation/
│   ├── providers/
│   │   ├── game_provider.dart
│   │   ├── score_provider.dart
│   │   └── animation_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── game_screen.dart
│   └── widgets/
│       ├── game_grid.dart
│       ├── block_widget.dart
│       ├── score_display.dart
│       └── floating_score.dart
└── app.dart
```

## 4. Konfigurasi Linting (analysis_options.yaml)

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    avoid_unnecessary_containers: true
    prefer_single_quotes: true
    use_key_in_widget_constructors: true

analyzer:
  errors:
    invalid_annotation_target: ignore
```

## 5. Riverpod Setup (main.dart)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: AuraGlideApp(),
    ),
  );
}
```

## 6. Running the App

```bash
flutter run
```

atau untuk menjalankan di device spesifik:

```bash
flutter run -d <device_id>
flutter devices  # lihat daftar device
```

## 7. Build for Release (Optional)

```bash
flutter build apk --release
flutter build ios --release  # perlu signing
```

---

**Catatan:**
- Semua dependency menggunakan versi stabil (latest stable)
- Riverpod untuk state management sesuai PRD requirement
- Hive/SharedPreferences untuk local storage high score
- Google Fonts untuk Quicksand