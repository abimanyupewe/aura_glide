import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/block.dart';
import '../../domain/entities/grid.dart';
import '../../domain/repositories/score_repository.dart';
import '../../domain/usecases/swap_blocks.dart';
import '../../domain/usecases/detect_matches.dart';
import '../../domain/usecases/apply_gravity.dart';
import '../../domain/usecases/calculate_score.dart';
import '../../domain/usecases/refill_grid.dart';
import 'providers.dart';

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    ref.read(swapBlocksProvider),
    ref.read(detectMatchesProvider),
    ref.read(applyGravityProvider),
    ref.read(calculateScoreProvider),
    ref.read(refillGridProvider),
    ref.read(scoreRepositoryProvider),
  );
});

class GameNotifier extends StateNotifier<GameState> {
  final SwapBlocks _swapBlocks;
  final DetectMatches _detectMatches;
  final ApplyGravity _applyGravity;
  final CalculateScore _calculateScore;
  final RefillGrid _refillGrid;
  final ScoreRepository _scoreRepository;
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  static const int _numColors = 4;

  GameNotifier(
    this._swapBlocks,
    this._detectMatches,
    this._applyGravity,
    this._calculateScore,
    this._refillGrid,
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
    var grid = Grid.empty(rows: 8, cols: 8);

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int type;
        do {
          type = _random.nextInt(_numColors);
        } while (_wouldCreateMatch(grid, row, col, type));

        final block = Block(
          id: _uuid.v4(),
          type: type,
          row: row,
          col: col,
        );
        grid = grid.setBlock(row, col, block);
      }
    }

    return grid;
  }

  bool _wouldCreateMatch(Grid grid, int row, int col, int type) {
    if (col >= 2) {
      final left1 = grid.getBlock(row, col - 1);
      final left2 = grid.getBlock(row, col - 2);
      if (left1 != null &&
          left2 != null &&
          left1.type == type &&
          left2.type == type) {
        return true;
      }
    }

    if (row >= 2) {
      final up1 = grid.getBlock(row - 1, col);
      final up2 = grid.getBlock(row - 2, col);
      if (up1 != null &&
          up2 != null &&
          up1.type == type &&
          up2.type == type) {
        return true;
      }
    }

    return false;
  }

  Future<void> swapBlocks(Block from, Block to) async {
    if (state.isAnimating) return;
    if (!_swapBlocks.isValidSwap(state.grid, from.row, from.col, to.row, to.col)) {
      return;
    }

    state = state.copyWith(isAnimating: true);

    final newGrid =
        _swapBlocks.execute(state.grid, from.row, from.col, to.row, to.col);
    final matches = _detectMatches.execute(newGrid);

    if (matches.isEmpty) {
      final revertedGrid =
          _swapBlocks.execute(newGrid, to.row, to.col, from.row, from.col);
      state = state.copyWith(grid: revertedGrid, isAnimating: false);
      return;
    }

    await _processMatches(newGrid, matches);
  }

  Future<void> _processMatches(Grid grid, List<List<Block>> matches) async {
    int totalPoints = 0;
    final List<Block> allMatchedBlocks = [];

    for (final match in matches) {
      final points = _calculateScore.execute(
        match.length,
        state.cascadeMultiplier,
      );
      totalPoints += points;
      allMatchedBlocks.addAll(match);
    }

    final newScore = state.score + totalPoints;
    final newHighScore = newScore > state.highScore ? newScore : state.highScore;

    if (newHighScore > state.highScore) {
      await _scoreRepository.saveHighScore(newHighScore);
    }

    var processedGrid = _removeBlocks(grid, allMatchedBlocks);
    await Future.delayed(const Duration(milliseconds: 200));

    processedGrid = _applyGravity.execute(processedGrid);
    await Future.delayed(const Duration(milliseconds: 200));

    processedGrid = _refillGrid.execute(processedGrid, _numColors);

    final cascadeMatches = _detectMatches.execute(processedGrid);

    if (cascadeMatches.isNotEmpty) {
      state = state.copyWith(
        grid: processedGrid,
        score: newScore,
        highScore: newHighScore,
        cascadeMultiplier: state.cascadeMultiplier + 1,
        isAnimating: false,
        lastMatches: matches
            .map((m) => MatchResult(blocks: m, points: totalPoints))
            .toList(),
      );

      await Future.delayed(const Duration(milliseconds: 300));
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

  Grid _removeBlocks(Grid grid, List<Block> blocks) {
    var newGrid = grid;
    for (final block in blocks) {
      newGrid = newGrid.setBlock(block.row, block.col, null);
    }
    return newGrid;
  }

  void selectBlock(Block block) {
    if (state.isAnimating) return;

    if (state.selectedBlock == null) {
      state = state.copyWith(selectedBlock: block);
    } else {
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