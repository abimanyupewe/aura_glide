import '../entities/grid.dart';
import '../entities/block.dart';

class DetectMatches {
  List<List<Block>> execute(Grid grid) {
    final List<List<Block>> allMatches = [];

    allMatches.addAll(_findHorizontalMatches(grid));
    allMatches.addAll(_findVerticalMatches(grid));

    return allMatches;
  }

  List<List<Block>> _findHorizontalMatches(Grid grid) {
    final List<List<Block>> matches = [];

    for (int row = 0; row < grid.rows; row++) {
      int matchStart = 0;
      int matchLength = 1;

      for (int col = 1; col <= grid.cols; col++) {
        final currentBlock =
            col < grid.cols ? grid.getBlock(row, col) : null;
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
    }

    return matches;
  }

  List<List<Block>> _findVerticalMatches(Grid grid) {
    final List<List<Block>> matches = [];

    for (int col = 0; col < grid.cols; col++) {
      int matchStart = 0;
      int matchLength = 1;

      for (int row = 1; row <= grid.rows; row++) {
        final currentBlock =
            row < grid.rows ? grid.getBlock(row, col) : null;
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
    }

    return matches;
  }
}