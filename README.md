# AuraGlide

A calming match-3 puzzle game built with Flutter.

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Requirements](#requirements)
- [Installation](#installation)
- [How to Play](#how-to-play)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [License](#license)

---

## About

AuraGlide is a relaxing match-3 puzzle game where you swipe blocks to match colors. No time limits, no pressure - just pure puzzle enjoyment. The game features smooth animations, cascade combos, and tracks your high score.

---

## Features

- **Swipe Controls** - Drag blocks in any direction (up, down, left, right)
- **Match 3+** - Connect blocks of the same color to score
- **Cascade Combos** - Chain matches for multiplied points
- **High Score Tracking** - Your best score is saved locally
- **Smooth Animations** - Bouncy effects, glow, and transitions
- **Responsive Design** - Works on various screen sizes
- **Clean UI** - Minimalist and calming aesthetic

---

## Screenshots

*(Add your app screenshots here)*

---

## Requirements

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android builds)

---

## Installation

### Option 1: Download Pre-built APK

If you prefer not to clone the code, you can download the pre-built APK directly:

**Download Link:** [AuraGlide APK on Google Drive](https://drive.google.com/drive/folders/1cdYueSHmnhk5gqN1DDY5KXwfbL222U9p?usp=drive_link)

Simply download the APK file and install it on your Android device.

---

### Option 2: Clone and Build

If you want to modify or build the app yourself, follow these steps:

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/aura_glide.git
cd aura_glide
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Run the App

Development mode:

```bash
flutter run
```

### Step 4: Build APK

Release APK:

```bash
flutter build apk --release
```

Debug APK:

```bash
flutter build apk --debug
```

The APK will be located at:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/flutter-apk/app-debug.apk`

---

## How to Play

1. **Start the Game**
   - Launch the app to see the home screen
   - Tap the "Play" button to begin

2. **Swipe Blocks**
   - Touch and drag any block in the direction you want
   - Blocks can be swiped up, down, left, or right
   - The block will swap places with the adjacent block

3. **Match Colors**
   - Connect 3 or more blocks of the same color
   - Matches can be horizontal or vertical
   - Matched blocks will disappear with a glow effect

4. **Score Points**
   - Each match awards points based on chain length
   - Cascade matches (chain reactions) multiply your score
   - Try to beat your high score!

5. **New Game**
   - Tap "New Game" anytime to restart

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget & navigation
├── core/
│   ├── constants/
│   │   ├── app_colors.dart   # Color definitions
│   │   ├── app_dimensions.dart # Size & spacing constants
│   │   └── app_typography.dart # Text styles
│   └── theme/
│       └── app_theme.dart    # Material theme config
├── data/
│   ├── datasources/
│   │   ├── local_storage.dart
│   │   └── shared_preferences_datasource.dart
│   └── repositories/
│       └── score_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── block.dart        # Block data model
│   │   ├── game_state.dart   # Game state model
│   │   └── grid.dart         # Grid data model
│   ├── repositories/
│   │   └── score_repository.dart
│   └── usecases/
│       ├── apply_gravity.dart
│       ├── calculate_score.dart
│       ├── detect_matches.dart
│       ├── refill_grid.dart
│       └── swap_blocks.dart
└── presentation/
    ├── providers/
    │   ├── game_provider.dart  # Game state management
    │   └── providers.dart      # Riverpod providers
    ├── screens/
    │   ├── game_screen.dart    # Main game screen
    │   └── home_screen.dart    # Home / menu screen
    └── widgets/
        ├── block_widget.dart   # Individual block with animations
        ├── game_grid.dart      # 8x8 game grid
        ├── how_to_play_dialog.dart # Tutorial popup
        └── score_display.dart  # Score & high score UI
```

---

## Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **Riverpod** - State management
- **SharedPreferences** - Local storage for high scores
- **UUID** - Unique ID generation for blocks

---

## Architecture

This project follows **Clean Architecture** principles:

- **Presentation Layer** - UI widgets, screens, state management
- **Domain Layer** - Business logic, entities, use cases
- **Data Layer** - Repositories, data sources, storage

---

## Customization

### Change Block Colors

Edit `lib/core/constants/app_colors.dart`:

```dart
static const List<Color> blockColors = [
  mintGreen,    // Color 1
  babyBlue,      // Color 2
  softPeach,     // Color 3
  lilac,         // Color 4
  lavender,      // Color 5
  softYellow,    // Color 6
];
```

### Change Grid Size

Edit `lib/core/constants/app_dimensions.dart`:

```dart
static const int gridRows = 8;
static const int gridCols = 8;
```

### Adjust Animation Speed

Edit `lib/core/constants/animation_constants.dart`:

```dart
static const Duration swapDuration = Duration(milliseconds: 300);
static const Duration gravityDuration = Duration(milliseconds: 400);
```

---

## Troubleshooting

### Build Errors

Make sure you have the latest Flutter SDK:

```bash
flutter doctor
flutter pub upgrade
```

### SharedPreferences Error

Ensure `shared_preferences` is in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
```

Then run:

```bash
flutter pub get
```

---

## License

This project is open source and available under the MIT License.

---

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

---

Enjoy the calming puzzle experience with AuraGlide!
