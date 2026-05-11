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