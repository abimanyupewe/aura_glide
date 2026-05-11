# Clean Architecture - AuraGlide

Dokumen ini menjelaskan arsitektur Clean Architecture yang digunakan dalam project AuraGlide.

## 1. Prinsip Arsitektur

AuraGlide menggunakan **Clean Architecture** dengan pemisahan layer yang tegas:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Screens, Widgets, Providers - Riverpod)                  │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                             │
│  (Entities, Use Cases, Repository Interfaces)              │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  (Repository Implementations, Data Sources, Models)        │
└─────────────────────────────────────────────────────────────┘
```

## 2. Struktur Folder Lengkap

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # App configuration
│
├── core/                              # Shared utilities
│   ├── constants/
│   │   ├── app_colors.dart           # Color constants
│   │   ├── app_typography.dart       # Typography definitions
│   │   └── app_dimensions.dart       # Sizes, paddings
│   ├── theme/
│   │   └── app_theme.dart            # ThemeData configuration
│   └── utils/
│       └── extensions.dart           # Helper extensions
│
├── domain/                            # Business Logic Layer
│   ├── entities/
│   │   ├── block.dart                # Block entity
│   │   ├── grid.dart                 # Grid entity
│   │   └── game_state.dart           # Game state entity
│   ├── repositories/
│   │   └── score_repository.dart     # Repository interface
│   └── usecases/
│       ├── swap_blocks.dart          # Swap use case
│       ├── detect_matches.dart       # Match detection
│       ├── apply_gravity.dart        # Gravity logic
│       ├── calculate_score.dart      # Score calculation
│       └── check_game_over.dart      # Game over check
│
├── data/                             # Data Layer
│   ├── repositories/
│   │   └── score_repository_impl.dart # Repository implementation
│   ├── datasources/
│   │   └── local_storage.dart        # Local storage (Hive/SP)
│   └── models/
│       └── game_state_model.dart     # Data model (JSON serializable)
│
└── presentation/                     # UI Layer
    ├── providers/
    │   ├── game_provider.dart        # Main game state provider
    │   ├── score_provider.dart        # Score management
    │   └── animation_provider.dart   # Animation state
    ├── screens/
    │   ├── home_screen.dart          # Main menu
    │   └── game_screen.dart          # Gameplay screen
    └── widgets/
        ├── game_grid.dart            # Grid container
        ├── block_widget.dart         # Individual block
        ├── score_display.dart        # Score UI
        └── floating_score.dart       # Animated score popup
```

## 3. Detail Setiap Layer

### Domain Layer (Business Logic)

**Tanggung Jawab:**
- Mendefinisikan business entities
- Berisi use cases/logika game
- Tidak bergantung pada Flutter/外部

**Entities:**

```dart
// block.dart
class Block {
  final String id;
  final int type; // 0-5 (warna block)
  final int row;
  final int col;

  const Block({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
  });

  Block copyWith({int? row, int? col}) {
    return Block(
      id: id,
      type: type,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }
}

// grid.dart
class Grid {
  final int rows;
  final int cols;
  final List<List<Block?>> blocks;

  const Grid({
    required this.rows,
    required this.cols,
    required this.blocks,
  });
  // ...
}
```

**Use Cases:**

```dart
// swap_blocks.dart
class SwapBlocks {
  Grid execute(Grid grid, int fromRow, int fromCol, int toRow, int toCol);
}

// detect_matches.dart
class DetectMatches {
  List<List<Position>> execute(Grid grid);
}

// apply_gravity.dart
class ApplyGravity {
  Grid execute(Grid grid);
}
```

### Data Layer (Data Access)

**Tanggung Jawab:**
- Mengimplementasikan repository interfaces
- Berkomunikasi dengan data sources
- Melakukan data transformation (Model <-> Entity)

**Repository Interface (Domain):**

```dart
// domain/repositories/score_repository.dart
abstract class ScoreRepository {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<void> clearScore();
}
```

**Repository Implementation (Data):**

```dart
// data/repositories/score_repository_impl.dart
class ScoreRepositoryImpl implements ScoreRepository {
  final LocalStorageDataSource _dataSource;

  ScoreRepositoryImpl(this._dataSource);

  @override
  Future<int> getHighScore() async {
    return await _dataSource.getHighScore();
  }

  @override
  Future<void> saveHighScore(int score) async {
    final currentHighScore = await getHighScore();
    if (score > currentHighScore) {
      await _dataSource.saveHighScore(score);
    }
  }
}
```

### Presentation Layer (UI)

**Tanggung Jawab:**
- Menampilkan UI ke user
- Menangani user interactions
- Menggunakan Riverpod untuk state management

**Providers (Riverpod):**

```dart
// presentation/providers/game_provider.dart
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    swapBlocks: ref.read(swapBlocksProvider),
    detectMatches: ref.read(detectMatchesProvider),
    applyGravity: ref.read(applyGravityProvider),
    calculateScore: ref.read(calculateScoreProvider),
  );
});

class GameNotifier extends StateNotifier<GameState> {
  final SwapBlocks _swapBlocks;
  final DetectMatches _detectMatches;
  final ApplyGravity _applyGravity;
  final CalculateScore _calculateScore;

  GameNotifier({
    required SwapBlocks swapBlocks,
    required DetectMatches detectMatches,
    required ApplyGravity applyGravity,
    required CalculateScore calculateScore,
  }) : super(GameState.initial()) {
    _initializeGrid();
  }
  // ...
}
```

## 4. Alur Data (Data Flow)

```
User Action (Tap/Swipe)
        │
        ▼
Presentation Layer (Widget)
        │
        ▼
Riverpod Provider (GameNotifier)
        │
        ▼
Domain Layer (Use Cases)
        │
        ▼
Domain Layer (Entities)
        │
        ▼
Data Layer (Repository)
        │
        ▼
Data Layer (DataSource - Hive/SharedPreferences)
        │
        ▼
Update State ──► UI Rebuild
```

## 5. Dependency Injection

Menggunakan Riverpod untuk dependency injection:

```dart
// providers barrel file
export 'game_provider.dart';
export 'score_provider.dart';
export 'animation_provider.dart';

// use case providers
final swapBlocksProvider = Provider<SwapBlocks>((ref) {
  return SwapBlocks();
});

final detectMatchesProvider = Provider<DetectMatches>((ref) {
  return DetectMatches();
});

final applyGravityProvider = Provider<ApplyGravity>((ref) {
  return ApplyGravity();
});

final calculateScoreProvider = Provider<CalculateScore>((ref) {
  return CalculateScore();
});

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  final dataSource = ref.read(localStorageProvider);
  return ScoreRepositoryImpl(dataSource);
});
```

## 6. Keuntungan Arsitektur

| Keuntungan | Penjelasan |
|------------|------------|
| **Testable** | Use cases bisa di-test tanpa UI |
| **Maintainable** | Perubahan di satu layer tidak affect layer lain |
| **Scalable** | Mudah tambah fitur baru |
| **Separation of Concerns** | Setiap layer punya tanggung jawab jelas |
| **Reusable** | Use cases bisa di-reuse di context berbeda |

## 7. Aturan Naming

- **Entities**: kata benda (Block, Grid, GameState)
- **Use Cases**: kata kerja + objek (SwapBlocks, DetectMatches)
- **Repositories**: noun + Repository (ScoreRepository)
- **Providers**: noun + Provider (gameProvider, scoreProvider)
- **Screens**: noun + Screen (HomeScreen, GameScreen)
- **Widgets**: noun + Widget (BlockWidget, GameGrid)

## 8. Additional Components

### Direction Enum (Block Swipe)

```dart
// presentation/widgets/block_widget.dart
enum Direction { up, down, left, right }

enum BlockAnimationState {
  idle,
  dragging,
  matched,
  falling,
}
```

### AppNavigator (Navigation)

```dart
// app.dart
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showGame = false;

  @override
  Widget build(BuildContext context) {
    if (_showGame) {
      return const GameScreen();
    }
    return HomeScreen(
      onPlayPressed: () {
        setState(() {
          _showGame = true;
        });
      },
    );
  }
}
```

### HowToPlayDialog Widget

```dart
// presentation/widgets/how_to_play_dialog.dart
class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const HowToPlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dialog dengan tutorial cara bermain
    // Terdapat icon, teks instruksi, dan tombol "Got it!"
  }
}
```

### Updated File Structure

```
lib/
├── main.dart
├── app.dart                           # AuraGlideApp + AppNavigator
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_dimensions.dart
│   │   └── animation_constants.dart
│   └── theme/
│       └── app_theme.dart
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
│       ├── calculate_score.dart
│       └── refill_grid.dart           # NEW: Fill empty cells
├── data/
│   ├── repositories/
│   │   └── score_repository_impl.dart
│   └── datasources/
│       ├── local_storage.dart
│       └── shared_preferences_datasource.dart
└── presentation/
    ├── providers/
    │   ├── providers.dart             # All use case providers
    │   └── game_provider.dart        # GameNotifier
    ├── screens/
    │   ├── home_screen.dart          # Main menu + highScoreProvider
    │   └── game_screen.dart         # Gameplay screen
    └── widgets/
        ├── game_grid.dart            # Grid with swipe support
        ├── block_widget.dart         # Block with gesture detection
        ├── score_display.dart        # Score UI
        └── how_to_play_dialog.dart  # Tutorial dialog (NEW)
```

---

**Referensi:**
- PRD Section 5: "Wajib menerapkan Clean Architecture"
- Flutter Clean Architecture Best Practices