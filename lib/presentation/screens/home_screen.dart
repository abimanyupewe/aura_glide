import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/providers.dart';
import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import '../../domain/entities/game_state.dart';

final highScoreProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(scoreRepositoryProvider);
  return repository.getHighScore();
});

class HomeScreen extends ConsumerWidget {
  final VoidCallback onPlayPressed;

  const HomeScreen({super.key, required this.onPlayPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highScoreAsync = ref.watch(highScoreProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'AuraGlide',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Calming Puzzle',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  highScoreAsync.when(
                    data: (highScore) {
                      if (highScore > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mintGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events_rounded,
                                  color: AppColors.accentWarning,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'High Score: $highScore',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  _buildPlayButton(
                    context, 
                    'Play Chill Mode', 
                    AppColors.mintGreen,
                    () {
                      ref.read(gameProvider.notifier).startGame(GameMode.chill);
                      onPlayPressed();
                    }
                  ),
                  const SizedBox(height: 16),
                  _buildPlayButton(
                    context, 
                    'Play Normal Mode', 
                    AppColors.babyBlue,
                    () {
                      ref.read(gameProvider.notifier).startGame(GameMode.normal);
                      onPlayPressed();
                    }
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Normal: Timeout 60s • Chill: Relax',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).state = 
                    themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}