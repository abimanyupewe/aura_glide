# Coding Standards - AuraGlide

Dokumen ini menjelaskan standar coding, prinsip SOLID, dan aturan linting yang harus diikuti dalam project AuraGlide.

## 1. Aturan Linting

### analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Style
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_single_quotes: true
    use_trailing_comma_for_fields: true
    sort_pub_dependencies: true

    # Best Practices
    avoid_print: true
    avoid_unnecessary_containers: true
    avoid_redundant_argument_values: false
    prefer_collection_literals: true
    prefer_if_null_operators: true
    prefer_null_aware_operators: true

    # Flutter Specific
    use_key_in_widget_constructors: true
    avoid_web_libraries_in_flutter: true

    # Naming
    avoid_empty_else: true
    prefer_interpolation_to_compose_strings: true
    prefer_is_empty: true
    prefer_is_not_empty: true

analyzer:
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error

  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
```

### Running Linter

```bash
# Check lint
flutter analyze

# Auto-fix some issues
flutter analyze --fix
```

## 2. Prinsip SOLID

### S - Single Responsibility Principle

```dart
// ✅ Good: Setiap class punya satu tanggung jawab
class Block extends Equatable {
  final String id;
  final int type;
  final int row;
  final int col;

  const Block({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
  });
}

// ❌ Bad: Class yang melakukan terlalu banyak
class GameManager {
  // Melakukan UI, logic, dan storage
  void render() { /* ... */ }
  void calculateScore() { /* ... */ }
  void saveToDb() { /* ... */ }
}
```

### O - Open/Closed Principle

```dart
// ✅ Good: Extendable tanpa modify existing code
abstract class MatchDetector {
  List<List<Block>> detect(Grid grid);
}

class HorizontalMatchDetector extends MatchDetector {
  @override
  List<List<Block>> detect(Grid grid) { /* ... */ }
}

class VerticalMatchDetector extends MatchDetector {
  @override
  List<List<Block>> detect(Grid grid) { /* ... */ }
}
```

### L - Liskov Substitution Principle

```dart
// ✅ Good: Subclass bisa menggantikan parent tanpa perubahan behavior
abstract class ScoreRepository {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
}

class SharedPreferencesScoreRepository implements ScoreRepository {
  @override
  Future<int> getHighScore() async { /* ... */ }

  @override
  Future<void> saveHighScore(int score) async { /* ... */ }
}

// Bisa diganti dengan Hive tanpa mengubah interface
class HiveScoreRepository implements ScoreRepository {
  @override
  Future<int> getHighScore() async { /* ... */ }

  @override
  Future<void> saveHighScore(int score) async { /* ... */ }
}
```

### I - Interface Segregation Principle

```dart
// ✅ Good: Specific interfaces daripada satu interface besar
abstract class GameUseCases {
  void swapBlocks(Block a, Block b);
  List<List<Block>> detectMatches();
  Grid applyGravity();
}

abstract class PersistenceUseCases {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
}

// ❌ Bad: Satu interface untuk semua
abstract class GameAndPersistence {
  void swap();
  void saveScore();
  // ... terlalu banyak method
}
```

### D - Dependency Inversion Principle

```dart
// ✅ Good: depend pada abstraksi, bukan konkret
class GameNotifier {
  final ScoreRepository _scoreRepository; // Abstraksi

  GameNotifier(this._scoreRepository); // Dimasukkan via constructor

  Future<void> saveScore() async {
    await _scoreRepository.saveHighScore(100);
  }
}

// ❌ Bad: depend pada konkret implementation
class BadGameNotifier {
  final SharedPreferencesScoreRepository _repository; // Langsung konkret

  BadGameNotifier() : _repository = SharedPreferencesScoreRepository();
}
```

## 3. Prinsip DRY (Don't Repeat Yourself)

### Bad (Repeated Code)

```dart
// ❌ Bad: Duplikasi
class BlockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class AnotherBlockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
```

### Good (Reusable Component)

```dart
// ✅ Good: Extract ke constants
class AppDimensions {
  static const double blockSize = 48.0;
  static const double blockBorderRadius = 16.0;
}

// ✅ Good: Reusable widget
class BlockWidget extends StatelessWidget {
  final Color color;

  const BlockWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.blockSize,
      height: AppDimensions.blockSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.blockBorderRadius),
      ),
    );
  }
}
```

### Good (Helper Methods)

```dart
// ✅ Good: Extract repeated logic ke helper
class GridHelper {
  static bool isValidPosition(Grid grid, int row, int col) {
    return row >= 0 && row < grid.rows && col >= 0 && col < grid.cols;
  }

  static bool isAdjacent(Block a, Block b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  static Block? getBlockOrNull(Grid grid, int row, int col) {
    if (!isValidPosition(grid, row, col)) return null;
    return grid.getBlock(row, col);
  }
}
```

## 4. Naming Conventions

### Variables & Functions

```dart
// snake_case untuk variables dan functions
final highScore = 100;
final blockList = <Block>[];
void calculateScore() { }
String getFormattedScore() { }
```

### Classes & Types

```dart
// PascalCase untuk class, enum, typedef
class GameState { }
enum GameStatus { playing, paused, gameOver }
typedef ScoreCallback = void Function(int score);
```

### Constants

```dart
// kCamelCase untuk constant names (Flutter convention)
const int kMaxBlocks = 8;
const double kBlockSize = 48.0;

// Atau SCREAMING_SNAKE_CASE untuk enum values dan static const
enum BlockType { mintGreen, babyBlue, softPeach }
static const int defaultGridSize = 8;
```

### Files

```dart
// snake_case.dart untuk nama file
// Contoh: game_provider.dart, block_widget.dart, app_colors.dart
```

### Private Members

```dart
// _underscore prefix untuk private members
class GameNotifier extends StateNotifier<GameState> {
  final ScoreRepository _scoreRepository; // Private
  int _currentScore = 0; // Private

  void _privateMethod() { } // Private method
}
```

## 5. Code Organization

### Barrel Files (Exports)

```dart
// domain/entities/entities.dart
export 'block.dart';
export 'grid.dart';
export 'game_state.dart';

// presentation/providers/providers.dart
export 'game_provider.dart';
export 'score_provider.dart';
export 'animation_provider.dart';
```

### Import Order

```dart
// 1. Flutter/Dart packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. External packages
import 'package:google_fonts/google_fonts.dart';

// 3. Internal packages (relative)
import '../../domain/entities/block.dart';
import '../../core/constants/app_colors.dart';

// 4. Local (same package)
import 'game_provider.dart';
```

### Grouping dalam Class

```dart
class GameNotifier extends StateNotifier<GameState> {
  // 1. Properties/Fields
  final SwapBlocks _swapBlocks;
  final DetectMatches _detectMatches;

  // 2. Constructor
  GameNotifier(this._swapBlocks, this._detectMatches);

  // 3. Public methods
  Future<void> swapBlocks(Block from, Block to) async { }

  // 4. Private methods
  Grid _generateInitialGrid() { }

  // 5. Getters
  int get score => state.score;
}
```

## 6. Error Handling

```dart
// ✅ Good: Specific exception types
class GameException implements Exception {
  final String message;
  final GameErrorType type;

  GameException(this.message, this.type);

  @override
  String toString() => 'GameException: $message (type: $type)';
}

enum GameErrorType {
  invalidSwap,
  gridOutOfBounds,
  storageError,
}

// ✅ Good: Result type pattern
Result<Grid, GameException> swapBlocks(Block a, Block b) {
  if (!_isValidSwap(a, b)) {
    return Result.failure(GameException('Invalid swap', GameErrorType.invalidSwap));
  }
  return Result.success(_performSwap(a, b));
}

// ✅ Good: Try-catch with context
Future<void> saveScore(int score) async {
  try {
    await _repository.saveHighScore(score);
  } on StorageException catch (e) {
    debugPrint('Failed to save score: $e');
    // Handle gracefully - don't crash app
  }
}
```

## 7. Testing Standards

```dart
// Naming: test_{method}_{expected_behavior}
test('detectMatches_shouldReturnHorizontalMatch', () { });

// Grouping
group('SwapBlocks', () {
  test('should swap adjacent blocks', () { });
  test('should return same grid for invalid swap', () { });
  test('should not swap diagonal blocks', () { });
});

// Arrange-Act-Assert
test('calculateScore_shouldMultiplyByCascade', () {
  // Arrange
  final calculateScore = CalculateScore();

  // Act
  final result = calculateScore.execute(3, 2);

  // Assert
  expect(result, 20); // 10 * 2
});
```

## 8. Git Commit Messages

```
feat: add cascade multiplier animation
fix: block swap not triggering match detection
refactor: extract grid helper methods
docs: update PRD with new color palette
chore: update dependencies to latest versions
```

---

**Referensi:**
- PRD Section 5: "Mengikuti prinsip SOLID dan kode yang DRY"
- Effective Dart Style Guide
- Flutter Lints