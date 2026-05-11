import 'package:equatable/equatable.dart';
import 'block.dart';
import 'grid.dart';

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
      selectedBlock:
          clearSelectedBlock ? null : (selectedBlock ?? this.selectedBlock),
      isAnimating: isAnimating ?? this.isAnimating,
      lastMatches: lastMatches ?? this.lastMatches,
    );
  }

  factory GameState.initial() {
    return GameState(
      grid: Grid.empty(rows: 8, cols: 8),
    );
  }

  @override
  List<Object?> get props => [
        grid,
        score,
        highScore,
        cascadeMultiplier,
        status,
        selectedBlock,
        isAnimating,
        lastMatches,
      ];
}

class MatchResult extends Equatable {
  final List<Block> blocks;
  final int points;

  const MatchResult({required this.blocks, required this.points});

  @override
  List<Object?> get props => [blocks, points];
}