import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../domain/entities/grid.dart';
import '../../domain/entities/block.dart';
import 'block_widget.dart';

class GameGrid extends StatefulWidget {
  final Grid grid;
  final Block? selectedBlock;
  final Function(Block) onBlockTap;
  final Function(Block, Direction) onBlockSwipe;
  final Set<String> matchedBlockIds;
  final Set<String> fallingBlockIds;
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

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableWidth = screenWidth - 32;
    final availableHeight = screenHeight - 280;

    final maxGridSize = availableWidth < availableHeight ? availableWidth : availableHeight;
    final totalSpacing = AppDimensions.gridSpacing * (AppDimensions.gridCols - 1);
    final blockSize = (maxGridSize - totalSpacing) / AppDimensions.gridCols;

    final gridWidth = (blockSize * AppDimensions.gridCols) + totalSpacing;
    final gridHeight = (blockSize * AppDimensions.gridRows) + totalSpacing;

    return Center(
      child: SizedBox(
        width: gridWidth,
        height: gridHeight,
        child: Stack(
          children: _buildBlocks(blockSize),
        ),
      ),
    );
  }

  List<Widget> _buildBlocks(double blockSize) {
    final blocks = <Widget>[];
    final gridSpacing = AppDimensions.gridSpacing;

    for (int row = 0; row < AppDimensions.gridRows; row++) {
      for (int col = 0; col < AppDimensions.gridCols; col++) {
        final block = widget.grid.getBlock(row, col);

        if (block != null) {
          final isMatched = widget.matchedBlockIds.contains(block.id);
          final isFalling = widget.fallingBlockIds.contains(block.id);
          final isSelected = widget.selectedBlock?.id == block.id;

          blocks.add(
            AnimatedPositioned(
              key: ValueKey('pos_${block.id}'),
              duration: Duration(
                milliseconds: isFalling ? 400 : 0,
              ),
              curve: Curves.bounceOut,
              left: col * (blockSize + gridSpacing),
              top: row * (blockSize + gridSpacing),
              child: SizedBox(
                width: blockSize,
                height: blockSize,
                child: BlockWidget(
                  key: ValueKey(block.id),
                  block: block,
                  isSelected: isSelected,
                  onSwipe: widget.onBlockSwipe,
                  onMatchComplete: isMatched
                      ? () {
                          if (widget.onAnimationComplete != null) {
                            widget.onAnimationComplete!();
                          }
                        }
                      : null,
                ),
              ),
            ),
          );
        }
      }
    }

    return blocks;
  }
}