import '../entities/grid.dart';
import '../entities/block.dart';

class ApplyGravity {
  Grid execute(Grid grid) {
    var newGrid = grid;

    for (int col = 0; col < grid.cols; col++) {
      final columnBlocks = <Block>[];
      for (int row = 0; row < grid.rows; row++) {
        final block = grid.getBlock(row, col);
        if (block != null) {
          columnBlocks.add(block);
        }
      }

      if (columnBlocks.length < grid.rows) {
        int newRow = grid.rows - 1;
        for (int i = columnBlocks.length - 1; i >= 0; i--) {
          final updatedBlock = columnBlocks[i].copyWith(row: newRow);
          newGrid = newGrid.setBlock(newRow, col, updatedBlock);
          newRow--;
        }

        for (int row = newRow; row >= 0; row--) {
          newGrid = newGrid.setBlock(row, col, null);
        }
      }
    }

    return newGrid;
  }
}