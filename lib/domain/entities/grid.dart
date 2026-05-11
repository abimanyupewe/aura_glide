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