# State Management - AuraGlide (Riverpod)

Dokumen ini menjelaskan implementasi state management menggunakan Riverpod dalam project AuraGlide.

## 1. Mengapa Riverpod?

Berdasarkan PRD requirements:
- **Wajib menggunakan Riverpod** untuk state management
- **Pemisahan Provider** berdasarkan layer arsitektur
- **Tidak mencampur** business logic di UI

Keuntungan Riverpod:
- Compile-time safety
- Testable
- No BuildContext needed
- Powerful code generation

## 2. Struktur Provider

```
presentation/providers/
├── game_provider.dart      # Main game state
├── score_provider.dart     # Score management
├── animation_provider.dart # Animation state
└── providers.dart          # Use case providers barrel
```

## 3. Provider Types yang Digunakan

| Type | Usage |
|------|-------|
| `Provider` | Use cases, repositories (dependency injection) |
| `StateNotifierProvider` | Complex state (GameState) |
| `StateProvider` | Simple state (animation flags) |
| `FutureProvider` | Async operations (load high score) |

## 4. Game State Provider (Main)

### GameState Entity

```dart
// domain/entities/game_state.dart
import 'package:equatable/equatable.dart';
import 'block.dart';

enum GameStatus { initial, playing, paused, gameOver }

class GameState extends Equatable {
  final Grid grid;
  final int score;
  final int highScore;
  final int cascadeMultiplier;
  final GameStatus status;
  final Block? selectedBlock;
  final bool isAnimating;
  final List<MatchResult> lastMatches;

  const GameState({
    required this.grid,
    this.score = 0,
    this.highScore = 0,
    this.cascadeMultiplier = 1,
    this.status = GameStatus.initial,
    this.selectedBlock,
    this.isAnimating = false,
    this.lastMatches = const [],
  });

  GameState copyWith({
    Grid? grid,
    int? score,
    int? highScore,
    int? cascadeMultiplier,
    GameStatus? status,
    Block? selectedBlock,
    bool? isAnimating,
    List<MatchResult>? lastMatches,
    bool clearSelectedBlock = false,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      cascadeMultiplier: cascadeMultiplier ?? this.cascadeMultiplier,
      status: status ?? this.status,
      selectedBlock: clearSelectedBlock ? null : (selectedBlock ?? this.selectedBlock),
      isAnimating: isAnimating ?? this.isAnimating,
      lastMatches: lastMatches ?? this.lastMatches,
    );
  }

  factory GameState.initial() {
    return GameState(
      grid: Grid.empty(rows: 8, cols: 8),
    );
  }
}

class MatchResult extends Equatable {
  final List<Block> blocks;
  final int points;

  const MatchResult({required this.blocks, required this.points});
}
```

### GameNotifier (StateNotifier)

```dart
// presentation/providers/game_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/block.dart';
import '../../domain/entities/grid.dart';
import 'providers.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    ref.read(swapBlocksProvider),
    ref.read(detectMatchesProvider),
    ref.read(applyGravityProvider),
    ref.read(calculateScoreProvider),
    ref.read(scoreRepositoryProvider),
  );
});

class GameNotifier extends StateNotifier<GameState> {
  final SwapBlocks _swapBlocks;
  final DetectMatches _detectMatches;
  final ApplyGravity _applyGravity;
  final CalculateScore _calculateScore;
  final ScoreRepository _scoreRepository;

  GameNotifier(
    this._swapBlocks,
    this._detectMatches,
    this._applyGravity,
    this._calculateScore,
    this._scoreRepository,
  ) : super(GameState.initial()) {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final highScore = await _scoreRepository.getHighScore();
    final grid = _generateInitialGrid();

    state = state.copyWith(
      grid: grid,
      highScore: highScore,
      status: GameStatus.playing,
    );
  }

  Grid _generateInitialGrid() {
    // Generate grid dengan random blocks
    // Pastikan tidak ada initial matches
  }

  Future<void> swapBlocks(Block from, Block to) async {
    if (state.isAnimating) return;

    state = state.copyWith(isAnimating: true);

    // Perform swap
    final newGrid = _swapBlocks.execute(state.grid, from.row, from.col, to.row, to.col);

    // Check matches
    final matches = _detectMatches.execute(newGrid);

    if (matches.isEmpty) {
      // No match - swap back
      final revertedGrid = _swapBlocks.execute(newGrid, to.row, to.col, from.row, from.col);
      state = state.copyWith(grid: revertedGrid, isAnimating: false);
      return;
    }

    // Process matches
    await _processMatches(newGrid, matches);
  }

  Future<void> _processMatches(Grid grid, List<List<Block>> matches) async {
    int totalPoints = 0;
    List<Block> allMatchedBlocks = [];

    for (final match in matches) {
      final points = _calculateScore.execute(
        match.length,
        state.cascadeMultiplier,
      );
      totalPoints += points;
      allMatchedBlocks.addAll(match);
    }

    // Update score
    final newScore = state.score + totalPoints;
    final newHighScore = newScore > state.highScore ? newScore : state.highScore;

    if (newHighScore > state.highScore) {
      await _scoreRepository.saveHighScore(newHighScore);
    }

    // Remove matched blocks
    var processedGrid = _removeBlocks(grid, allMatchedBlocks);

    // Apply gravity
    processedGrid = _applyGravity.execute(processedGrid);

    // Refill grid
    processedGrid = _refillGrid(processedGrid);

    // Check for cascade matches
    final cascadeMatches = _detectMatches.execute(processedGrid);

    if (cascadeMatches.isNotEmpty) {
      state = state.copyWith(
        grid: processedGrid,
        score: newScore,
        highScore: newHighScore,
        cascadeMultiplier: state.cascadeMultiplier + 1,
        isAnimating: false,
        lastMatches: matches.map((m) => MatchResult(blocks: m, points: totalPoints)).toList(),
      );

      // Continue cascade after animation
      await Future.delayed(const Duration(milliseconds: 500));
      await _processMatches(processedGrid, cascadeMatches);
    } else {
      state = state.copyWith(
        grid: processedGrid,
        score: newScore,
        highScore: newHighScore,
        cascadeMultiplier: 1,
        isAnimating: false,
        lastMatches: [],
      );
    }
  }

  Grid _removeBlocks(Grid grid, List<Block> blocks) { /* ... */ }
  Grid _refillGrid(Grid grid) { /* ... */ }

  void selectBlock(Block block) {
    if (state.isAnimating) return;

    if (state.selectedBlock == null) {
      state = state.copyWith(selectedBlock: block);
    } else {
      // Check if adjacent
      final isAdjacent = _isAdjacent(state.selectedBlock!, block);
      if (isAdjacent) {
        swapBlocks(state.selectedBlock!, block);
      }
      state = state.copyWith(clearSelectedBlock: true);
    }
  }

  bool _isAdjacent(Block a, Block b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  void resetGame() {
    state = GameState.initial();
    _initializeGame();
  }
}
```

## 5. Score Provider

```dart
// presentation/providers/score_provider.dart
final scoreProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(scoreRepositoryProvider);
  return await repository.getHighScore();
});

class ScoreManager {
  final Ref _ref;

  ScoreManager(this._ref);

  Future<void> updateHighScore(int score) async {
    final repository = _ref.read(scoreRepositoryProvider);
    await repository.saveHighScore(score);
  }
}
```

## 6. Animation Provider

```dart
// presentation/providers/animation_provider.dart
final animationDurationProvider = Provider<Duration>((ref) {
  return const Duration(milliseconds: 300);
});

final isBlockAnimatingProvider = StateProvider<bool>((ref) => false);

final springDescriptionProvider = Provider<SpringDescription>((ref) {
  return SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );
});
```

## 7. Use Case Providers (Dependency Injection)

```dart
// presentation/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/swap_blocks.dart';
import '../../domain/usecases/detect_matches.dart';
import '../../domain/usecases/apply_gravity.dart';
import '../../domain/usecases/calculate_score.dart';
import '../../domain/repositories/score_repository.dart';
import '../../data/repositories/score_repository_impl.dart';
import '../../data/datasources/local_storage.dart';

// Use Case Providers
final swapBlocksProvider = Provider<SwapBlocks>((ref) => SwapBlocks());
final detectMatchesProvider = Provider<DetectMatches>((ref) => DetectMatches());
final applyGravityProvider = Provider<ApplyGravity>((ref) => ApplyGravity());
final calculateScoreProvider = Provider<CalculateScore>((ref) => CalculateScore());

// Data Source Providers
final localStorageProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSourceImpl();
});

// Repository Providers
final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  final dataSource = ref.read(localStorageProvider);
  return ScoreRepositoryImpl(dataSource);
});
```

## 8. Penggunaan di Widget

```dart
// presentation/screens/game_screen.dart
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      body: Column(
        children: [
          ScoreDisplay(
            score: gameState.score,
            highScore: gameState.highScore,
            multiplier: gameState.cascadeMultiplier,
          ),
          Expanded(
            child: GameGrid(
              grid: gameState.grid,
              selectedBlock: gameState.selectedBlock,
              onBlockTap: (block) {
                ref.read(gameProvider.notifier).selectBlock(block);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 9. Catatan Penting

- **Pisahkan** provider berdasarkan tanggung jawab
- **Gunakan** `ref.watch` untuk listening state changes
- **Gunakan** `ref.read` untuk actions (tanpa rebuild)
- **StateNotifier** untuk state kompleks yang butuh update logic
- **FutureProvider** untuk async operations
- Hindari mencampur business logic di dalam widget

## 10. Additional Features

### High Score Provider (Home Screen)

```dart
// presentation/screens/home_screen.dart
final highScoreProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(scoreRepositoryProvider);
  return repository.getHighScore();
});

class HomeScreen extends ConsumerWidget {
  final VoidCallback onPlayPressed;

  const HomeScreen({super.key, required this.onPlayPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highScoreAsync = ref.watch(highScoreProvider);

    // Tampilkan high score jika > 0
    highScoreAsync.when(
      data: (highScore) {
        if (highScore > 0) {
          // Tampilkan container "High Score: $highScore"
        }
      },
      // ...
    );
  }
}
```

### Matched & Falling Block IDs (GameNotifier)

```dart
// presentation/providers/game_provider.dart
class GameNotifier extends StateNotifier<GameState> {
  Set<String> _matchedBlockIds = {};
  Set<String> _fallingBlockIds = {};

  Set<String> get matchedBlockIds => _matchedBlockIds;
  Set<String> get fallingBlockIds => _fallingBlockIds;

  // Usage dalam _processMatches:
  Future<void> _processMatches(Grid grid, List<List<Block>> matches) async {
    // ... process matches ...

    // Set matched blocks untuk animasi
    _matchedBlockIds = allMatchedBlocks.map((b) => b.id).toSet();
    state = state.copyWith(lastMatches: matches...);

    await Future.delayed(const Duration(milliseconds: 450));

    var processedGrid = _removeBlocks(grid, allMatchedBlocks);
    _matchedBlockIds = {};

    // Set falling blocks untuk animasi gravity
    _fallingBlockIds = _getFallingBlocks(processedGrid);
    state = state.copyWith(grid: processedGrid);

    await Future.delayed(const Duration(milliseconds: 450));

    processedGrid = _applyGravity.execute(processedGrid);
    state = state.copyWith(grid: processedGrid);

    await Future.delayed(const Duration(milliseconds: 450));

    processedGrid = _refillGrid.execute(processedGrid, _numColors);
    _fallingBlockIds = {};

    // ... cascade logic
  }

  Set<String> _getFallingBlocks(Grid grid) {
    final falling = <String>{};
    for (int row = 0; row < grid.rows; row++) {
      for (int col = 0; col < grid.cols; col++) {
        final block = grid.getBlock(row, col);
        if (block != null) {
          falling.add(block.id);
        }
      }
    }
    return falling;
  }
}
```

### GameGrid dengan Swipe Support

```dart
// presentation/widgets/game_grid.dart
class GameGrid extends StatefulWidget {
  final Grid grid;
  final Block? selectedBlock;
  final Function(Block) onBlockTap;
  final Function(Block, Direction) onBlockSwipe;  // NEW
  final Set<String> matchedBlockIds;                // NEW
  final Set<String> fallingBlockIds;                // NEW
  final VoidCallback? onAnimationComplete;

  const GameGrid({
    super.key,
    required this.grid,
    this.selectedBlock,
    required this.onBlockTap,
    required this.onBlockSwipe,
    this.matchedBlockIds = const {},
    this.fallingBlockIds = const {},
    this.onAnimationComplete,
  });

  // ...
}
```

---

**Referensi:**
- PRD Section 5: "State Management: Riverpod"
- Riverpod Documentation