# Game Logic - Use Cases

Dokumen ini menjelaskan implementasi algoritma game logic (use cases) dalam AuraGlide.

## 1. Overview Use Cases

| Use Case | Responsibility |
|----------|----------------|
| SwapBlocks | Menukar posisi dua blok |
| DetectMatches | Mendeteksi pola match-3+ |
| ApplyGravity | Menggerakkan blok ke bawah |
| CalculateScore | Menghitung poin dari match |
| CheckGameOver | Memeriksa apakah game selesai |

## 2. Entity Definitions

### Position

```dart
// domain/entities/position.dart
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
```

### Block Entity

```dart
// domain/entities/block.dart
import 'package:equatable/equatable.dart';

class Block extends Equatable {
  final String id;
  final int type; // 0-5 (warna block)
  final int row;
  final int col;
  final bool isMatched; // Untuk animasi removal

  const Block({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.isMatched = false,
  });

  Block copyWith({
    int? row,
    int? col,
    bool? isMatched,
  }) {
    return Block(
      id: id,
      type: type,
      row: row ?? this.row,
      col: col ?? this.col,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  List<Object?> get props => [id, type, row, col, isMatched];
}
```

### Grid Entity

```dart
// domain/entities/grid.dart
import 'package:equatable/equatable.dart';
import 'block.dart';

class Grid extends Equatable {
  final int rows;
  final int cols;
  final List<List<Block?>> blocks;

  const Grid({
    required this.rows,
    required this.cols,
    required this.blocks,
  });

  factory Grid.empty({int rows = 8, int cols = 8}) {
    return Grid(
      rows: rows,
      cols: cols,
      blocks: List.generate(
        rows,
        (_) => List.generate(cols, (_) => null),
      ),
    );
  }

  Block? getBlock(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return blocks[row][col];
  }

  Grid setBlock(int row, int col, Block? block) {
    final newBlocks = blocks.map((r) => r.toList()).toList();
    newBlocks[row][col] = block;
    return Grid(rows: rows, cols: cols, blocks: newBlocks);
  }

  Grid copyWith({List<List<Block?>>? blocks}) {
    return Grid(
      rows: rows,
      cols: cols,
      blocks: blocks ?? this.blocks,
    );
  }

  @override
  List<Object?> get props => [rows, cols, blocks];
}
```

## 3. Swap Blocks Use Case

```dart
// domain/usecases/swap_blocks.dart
import '../entities/grid.dart';
import '../entities/block.dart';

class SwapBlocks {
  Grid execute(Grid grid, int fromRow, int fromCol, int toRow, int toCol) {
    final fromBlock = grid.getBlock(fromRow, fromCol);
    final toBlock = grid.getBlock(toRow, toCol);

    if (fromBlock == null || toBlock == null) {
      return grid; // Invalid swap
    }

    // Create new blocks with swapped positions
    final newFromBlock = fromBlock.copyWith(row: toRow, col: toCol);
    final newToBlock = toBlock.copyWith(row: fromRow, col: fromCol);

    // Update grid
    return grid
        .setBlock(fromRow, fromCol, newToBlock)
        .setBlock(toRow, toCol, newFromBlock);
  }

  bool isValidSwap(Grid grid, int fromRow, int fromCol, int toRow, int toCol) {
    // Check bounds
    if (toRow < 0 || toRow >= grid.rows || toCol < 0 || toCol >= grid.cols) {
      return false;
    }

    // Check adjacency (only 4 directions)
    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();

    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
}
```

## 4. Detect Matches Use Case

```dart
// domain/usecases/detect_matches.dart
import '../entities/grid.dart';
import '../entities/block.dart';

class DetectMatches {
  List<List<Block>> execute(Grid grid) {
    final List<List<Block>> allMatches = [];

    // Check horizontal matches
    allMatches.addAll(_findHorizontalMatches(grid));

    // Check vertical matches
    allMatches.addAll(_findVerticalMatches(grid));

    return allMatches;
  }

  List<List<Block>> _findHorizontalMatches(Grid grid) {
    final List<List<Block>> matches = [];

    for (int row = 0; row < grid.rows; row++) {
      int matchStart = 0;
      int matchLength = 1;

      for (int col = 1; col <= grid.cols; col++) {
        final currentBlock = grid.getBlock(row, col);
        final previousBlock = grid.getBlock(row, matchStart);

        if (currentBlock != null &&
            previousBlock != null &&
            currentBlock.type == previousBlock.type) {
          matchLength++;
        } else {
          if (matchLength >= 3) {
            final match = <Block>[];
            for (int i = 0; i < matchLength; i++) {
              final block = grid.getBlock(row, matchStart + i);
              if (block != null) match.add(block);
            }
            if (match.isNotEmpty) matches.add(match);
          }
          matchStart = col;
          matchLength = 1;
        }
      }

      // Check end of row
      if (matchLength >= 3) {
        final match = <Block>[];
        for (int i = 0; i < matchLength; i++) {
          final block = grid.getBlock(row, matchStart + i);
          if (block != null) match.add(block);
        }
        if (match.isNotEmpty) matches.add(match);
      }
    }

    return matches;
  }

  List<List<Block>> _findVerticalMatches(Grid grid) {
    final List<List<Block>> matches = [];

    for (int col = 0; col < grid.cols; col++) {
      int matchStart = 0;
      int matchLength = 1;

      for (int row = 1; row <= grid.rows; row++) {
        final currentBlock = grid.getBlock(row, col);
        final previousBlock = grid.getBlock(matchStart, col);

        if (currentBlock != null &&
            previousBlock != null &&
            currentBlock.type == previousBlock.type) {
          matchLength++;
        } else {
          if (matchLength >= 3) {
            final match = <Block>[];
            for (int i = 0; i < matchLength; i++) {
              final block = grid.getBlock(matchStart + i, col);
              if (block != null) match.add(block);
            }
            if (match.isNotEmpty) matches.add(match);
          }
          matchStart = row;
          matchLength = 1;
        }
      }

      // Check end of column
      if (matchLength >= 3) {
        final match = <Block>[];
        for (int i = 0; i < matchLength; i++) {
          final block = grid.getBlock(matchStart + i, col);
          if (block != null) match.add(block);
        }
        if (match.isNotEmpty) matches.add(match);
      }
    }

    return matches;
  }
}
```

## 5. Apply Gravity Use Case

```dart
// domain/usecases/apply_gravity.dart
import '../entities/grid.dart';
import '../entities/block.dart';

class ApplyGravity {
  Grid execute(Grid grid) {
    var newGrid = grid;
    bool hasChanges = false;

    // Process each column
    for (int col = 0; col < grid.cols; col++) {
      // Collect non-null blocks in this column
      final columnBlocks = <Block>[];
      for (int row = 0; row < grid.rows; row++) {
        final block = grid.getBlock(row, col);
        if (block != null) {
          columnBlocks.add(block);
        }
      }

      // Check if gravity is needed
      if (columnBlocks.length < grid.rows) {
        hasChanges = true;

        // Place blocks at bottom
        int newRow = grid.rows - 1;
        for (int i = columnBlocks.length - 1; i >= 0; i--) {
          final updatedBlock = columnBlocks[i].copyWith(row: newRow);
          newGrid = newGrid.setBlock(newRow, col, updatedBlock);
          newRow--;
        }

        // Clear remaining cells
        for (int row = newRow; row >= 0; row--) {
          newGrid = newGrid.setBlock(row, col, null);
        }
      }
    }

    return newGrid;
  }

  // Get drop distance for animation
  Map<String, int> getDropDistances(Grid oldGrid, Grid newGrid) {
    final distances = <String, int>{};

    for (int row = 0; row < newGrid.rows; row++) {
      for (int col = 0; col < newGrid.cols; col++) {
        final newBlock = newGrid.getBlock(row, col);
        if (newBlock != null) {
          // Find original position
          for (int oldRow = 0; oldRow < oldGrid.rows; oldRow++) {
            final oldBlock = oldGrid.getBlock(oldRow, col);
            if (oldBlock != null && oldBlock.id == newBlock.id) {
              final distance = oldRow - row;
              if (distance > 0) {
                distances[newBlock.id] = distance;
              }
              break;
            }
          }
        }
      }
    }

    return distances;
  }
}
```

## 6. Calculate Score Use Case

```dart
// domain/usecases/calculate_score.dart
class CalculateScore {
  static const int basePointsPerBlock = 10;
  static const int additionalPointsPerBlock = 5;

  int execute(int matchLength, int cascadeMultiplier) {
    // Base: 3 blocks = 10 points
    // Additional: each extra block = +5 points
    // Example: 3 blocks = 10, 4 blocks = 15, 5 blocks = 20

    final basePoints = basePointsPerBlock +
        ((matchLength - 3) * additionalPointsPerBlock);

    // Apply cascade multiplier
    return basePoints * cascadeMultiplier;
  }

  // Breakdown for UI display
  ScoreBreakdown calculateBreakdown(int matchLength, int cascadeMultiplier) {
    final basePoints = basePointsPerBlock +
        ((matchLength - 3) * additionalPointsPerBlock);
    final totalPoints = basePoints * cascadeMultiplier;

    return ScoreBreakdown(
      basePoints: basePoints,
      multiplier: cascadeMultiplier,
      totalPoints: totalPoints,
      blockCount: matchLength,
    );
  }
}

class ScoreBreakdown {
  final int basePoints;
  final int multiplier;
  final int totalPoints;
  final int blockCount;

  const ScoreBreakdown({
    required this.basePoints,
    required this.multiplier,
    required this.totalPoints,
    required this.blockCount,
  });
}
```

## 7. Refill Grid Use Case

```dart
// domain/usecases/refill_grid.dart
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../entities/grid.dart';
import '../entities/block.dart';

class RefillGrid {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  Grid execute(Grid grid, int numColors) {
    var newGrid = grid;

    for (int col = 0; col < grid.cols; col++) {
      for (int row = 0; row < grid.rows; row++) {
        if (newGrid.getBlock(row, col) == null) {
          final newBlock = Block(
            id: _uuid.v4(),
            type: _random.nextInt(numColors),
            row: row,
            col: col,
          );
          newGrid = newGrid.setBlock(row, col, newBlock);
        }
      }
    }

    return newGrid;
  }
}
```

### Usage in GameNotifier

```dart
// presentation/providers/game_provider.dart
static const int _numColors = 4;

// Dalam _processMatches:
processedGrid = _refillGrid.execute(processedGrid, _numColors);
```

## 8. Check Game Over Use Case

```dart
// domain/usecases/check_game_over.dart
import '../entities/grid.dart';
import '../entities/block.dart';
import 'swap_blocks.dart';

class CheckGameOver {
  final SwapBlocks _swapBlocks = SwapBlocks();

  GameOverResult execute(Grid grid) {
    // Check if any valid moves exist
    final validMoves = getValidMoves(grid);

    if (validMoves.isEmpty) {
      return GameOverResult(
        isGameOver: true,
        reason: GameOverReason.noValidMoves,
        possibleMoves: 0,
      );
    }

    return GameOverResult(
      isGameOver: false,
      reason: null,
      possibleMoves: validMoves.length,
    );
  }

  List<ValidMove> getValidMoves(Grid grid) {
    final validMoves = <ValidMove>[];

    // Try swapping each block in 4 directions
    for (int row = 0; row < grid.rows; row++) {
      for (int col = 0; col < grid.cols; col++) {
        final block = grid.getBlock(row, col);
        if (block == null) continue;

        // Try each direction
        final directions = [
          (row - 1, col), // Up
          (row + 1, col), // Down
          (row, col - 1), // Left
          (row, col + 1), // Right
        ];

        for (final (toRow, toCol) in directions) {
          if (_swapBlocks.isValidSwap(grid, row, col, toRow, toCol)) {
            final swappedGrid = _swapBlocks.execute(grid, row, col, toRow, toCol);

            // Check if this swap creates a match
            final hasMatch = _wouldCreateMatch(swappedGrid, row, col, toRow, toCol);

            if (hasMatch) {
              validMoves.add(ValidMove(
                fromRow: row,
                fromCol: col,
                toRow: toRow,
                toCol: toCol,
              ));
            }
          }
        }
      }
    }

    return validMoves;
  }

  bool _wouldCreateMatch(Grid grid, int r1, int c1, int r2, int c2) {
    // Check horizontal
    for (int row = 0; row < grid.rows; row++) {
      int count = 1;
      for (int col = 1; col < grid.cols; col++) {
        final current = grid.getBlock(row, col);
        final previous = grid.getBlock(row, col - 1);
        if (current != null && previous != null &&
            current.type == previous.type) {
          count++;
        } else {
          if (count >= 3) return true;
          count = 1;
        }
      }
      if (count >= 3) return true;
    }

    // Check vertical
    for (int col = 0; col < grid.cols; col++) {
      int count = 1;
      for (int row = 1; row < grid.rows; row++) {
        final current = grid.getBlock(row, col);
        final previous = grid.getBlock(row - 1, col);
        if (current != null && previous != null &&
            current.type == previous.type) {
          count++;
        } else {
          if (count >= 3) return true;
          count = 1;
        }
      }
      if (count >= 3) return true;
    }

    return false;
  }
}

class GameOverResult {
  final bool isGameOver;
  final GameOverReason? reason;
  final int possibleMoves;

  const GameOverResult({
    required this.isGameOver,
    required this.reason,
    required this.possibleMoves,
  });
}

enum GameOverReason {
  noValidMoves,
  noBlocks,
}
```

## 9. Handle Swipe (GameNotifier)

```dart
// presentation/providers/game_provider.dart
enum Direction { up, down, left, right }

Future<void> handleSwipe(Block block, Direction direction) async {
  if (state.isAnimating) return;

  int targetRow = block.row;
  int targetCol = block.col;

  switch (direction) {
    case Direction.up:
      targetRow = block.row - 1;
      break;
    case Direction.down:
      targetRow = block.row + 1;
      break;
    case Direction.left:
      targetCol = block.col - 1;
      break;
    case Direction.right:
      targetCol = block.col + 1;
      break;
  }

  // Check bounds
  if (targetRow < 0 ||
      targetRow >= state.grid.rows ||
      targetCol < 0 ||
      targetCol >= state.grid.cols) {
    return;
  }

  final targetBlock = state.grid.getBlock(targetRow, targetCol);
  if (targetBlock == null) return;

  await swapBlocks(block, targetBlock);
}
```

## 10. Testing Use Cases

```dart
// test/domain/usecases/detect_matches_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_glide/domain/usecases/detect_matches.dart';
import 'package:aura_glide/domain/entities/grid.dart';
import 'package:aura_glide/domain/entities/block.dart';

void main() {
  late DetectMatches detectMatches;

  setUp(() {
    detectMatches = DetectMatches();
  });

  test('should detect horizontal match of 3', () {
    final grid = Grid(rows: 3, cols: 3, blocks: [
      [null, null, null],
      [
        const Block(id: '1', type: 0, row: 1, col: 0),
        const Block(id: '2', type: 0, row: 1, col: 1),
        const Block(id: '3', type: 0, row: 1, col: 2),
      ],
      [null, null, null],
    ]);

    final matches = detectMatches.execute(grid);

    expect(matches.length, 1);
    expect(matches[0].length, 3);
  });

  // ... more tests
}
```

---

**Referensi:**
- PRD Section 3: Core Mechanics
- Clean Architecture: Use Cases