import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/score_display.dart';
import '../widgets/how_to_play_dialog.dart';
import '../../domain/entities/game_state.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownDialog) {
        _hasShownDialog = true;
        HowToPlayDialog.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            if (gameState.mode == GameMode.normal)
              Text(
                'Time Left: ${gameState.timeLeft}s',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: gameState.timeLeft <= 10 ? AppColors.accentWarning : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              )
            else
              Text(
                'Chill Mode',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            const Spacer(),
            if (gameState.status == GameStatus.gameOver)
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'Time\'s Up!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.accentWarning,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              )
            else
              GameGrid(
                grid: gameState.grid,
                selectedBlock: gameState.selectedBlock,
                matchedBlockIds: notifier.matchedBlockIds,
                fallingBlockIds: notifier.fallingBlockIds,
                onBlockTap: (block) {
                  ref.read(gameProvider.notifier).selectBlock(block);
                },
                onBlockSwipe: (block, direction) {
                  ref.read(gameProvider.notifier).handleSwipe(block, direction);
                },
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  ref.read(gameProvider.notifier).resetGame();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.mintGreen,
                        AppColors.mintGreen.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mintGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'New Game',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
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