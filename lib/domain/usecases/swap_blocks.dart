import '../entities/grid.dart';

class SwapBlocks {
  Grid execute(
      Grid grid, int fromRow, int fromCol, int toRow, int toCol) {
    final fromBlock = grid.getBlock(fromRow, fromCol);
    final toBlock = grid.getBlock(toRow, toCol);

    if (fromBlock == null || toBlock == null) {
      return grid;
    }

    final newFromBlock = fromBlock.copyWith(row: toRow, col: toCol);
    final newToBlock = toBlock.copyWith(row: fromRow, col: fromCol);

    return grid
        .setBlock(fromRow, fromCol, newToBlock)
        .setBlock(toRow, toCol, newFromBlock);
  }

  bool isValidSwap(Grid grid, int fromRow, int fromCol, int toRow, int toCol) {
    if (toRow < 0 || toRow >= grid.rows || toCol < 0 || toCol >= grid.cols) {
      return false;
    }

    final rowDiff = (fromRow - toRow).abs();
    final colDiff = (fromCol - toCol).abs();

    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
}