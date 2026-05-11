import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../domain/entities/grid.dart';
import '../../domain/entities/block.dart';
import 'block_widget.dart';

class GameGrid extends StatelessWidget {
  final Grid grid;
  final Block? selectedBlock;
  final Function(Block) onBlockTap;

  const GameGrid({
    super.key,
    required this.grid,
    this.selectedBlock,
    required this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: (AppDimensions.blockSize * AppDimensions.gridCols) +
            (AppDimensions.gridSpacing * (AppDimensions.gridCols - 1)),
        height: (AppDimensions.blockSize * AppDimensions.gridRows) +
            (AppDimensions.gridSpacing * (AppDimensions.gridRows - 1)),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppDimensions.gridCols,
            mainAxisSpacing: AppDimensions.gridSpacing,
            crossAxisSpacing: AppDimensions.gridSpacing,
          ),
          itemCount: AppDimensions.gridRows * AppDimensions.gridCols,
          itemBuilder: (context, index) {
            final row = index ~/ AppDimensions.gridCols;
            final col = index % AppDimensions.gridCols;
            final block = grid.getBlock(row, col);

            if (block == null) {
              return SizedBox(
                width: AppDimensions.blockSize,
                height: AppDimensions.blockSize,
              );
            }

            final isSelected = selectedBlock?.id == block.id;

            return BlockWidget(
              block: block,
              isSelected: isSelected,
              onTap: () => onBlockTap(block),
            );
          },
        ),
      ),
    );
  }
}