import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/score_display.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            ScoreDisplay(
              score: gameState.score,
              highScore: gameState.highScore,
              multiplier: gameState.cascadeMultiplier,
            ),
            const SizedBox(height: 8),
            Text(
              'Match 3 blocks to score!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            GameGrid(
              grid: gameState.grid,
              selectedBlock: gameState.selectedBlock,
              onBlockTap: (block) {
                ref.read(gameProvider.notifier).selectBlock(block);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(gameProvider.notifier).resetGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintGreen,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'New Game',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}