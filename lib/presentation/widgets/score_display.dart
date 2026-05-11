import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class ScoreDisplay extends StatefulWidget {
  final int score;
  final int highScore;
  final int multiplier;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.highScore,
    this.multiplier = 1,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _rollController;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _displayedScore = widget.score;
  }

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animateScoreChange(oldWidget.score, widget.score);
    }
  }

  void _animateScoreChange(int from, int to) {
    _rollController.reset();
    _rollController.addListener(_updateDisplayedScore(from, to));
    _rollController.forward();
  }

  VoidCallback _updateDisplayedScore(int from, int to) {
    return () {
      final progress = Curves.easeOut.transform(_rollController.value);
      final current = from + ((to - from) * progress).round();
      setState(() {
        _displayedScore = current;
      });
    };
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _displayedScore.toString(),
          style: AppTypography.scoreDisplay,
        ),
        const SizedBox(height: 4),
        Text(
          'Best: ${widget.highScore}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (widget.multiplier > 1)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentWarning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.multiplier}x',
              style: AppTypography.multiplier,
            ),
          ),
      ],
    );
  }
}