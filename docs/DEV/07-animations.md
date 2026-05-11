# Animations - AuraGlide

Dokumen ini menjelaskan implementasi animasi modern dalam AuraGlide menggunakan prinsip physics-based animations.

## 1. Animation Principles

Berdasarkan PRD Section 2:
- **Physics-based Animations** menggunakan Spring Simulation
- **Organic movement** dengan bounce/bounciness
- **Squish Effect** saat block di-hold (scale 0.95)
- **60 FPS** performance target

## 2. Spring Animation Configuration

### SpringDescription

```dart
// core/constants/animation_constants.dart
import 'package:flutter/physics.dart';

class AnimationConstants {
  AnimationConstants._();

  // Swap animation (bouncy but controlled)
  static const SpringDescription swapSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  // Gravity animation (slightly heavier feel)
  static const SpringDescription gravitySpring = SpringDescription(
    mass: 1.5,
    stiffness: 200.0,
    damping: 25.0,
  );

  // Squish effect (quick snap)
  static const SpringDescription squishSpring = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 15.0,
  );

  // Floating score (gentle float)
  static const SpringDescription floatSpring = SpringDescription(
    mass: 0.5,
    stiffness: 100.0,
    damping: 12.0,
  );

  // Durations
  static const Duration swapDuration = Duration(milliseconds: 300);
  static const Duration gravityDuration = Duration(milliseconds: 400);
  static const Duration squishDuration = Duration(milliseconds: 150);
  static const Duration fadeOutDuration = Duration(milliseconds: 200);
  static const Duration floatUpDuration = Duration(milliseconds: 800);
  static const Duration scoreRollDuration = Duration(milliseconds: 500);
}
```

## 3. Block Widget with Animations

```dart
// presentation/widgets/block_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/animation_constants.dart';
import '../../domain/entities/block.dart';

class BlockWidget extends StatefulWidget {
  final Block block;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback? onTap;
  final Function(AnimationController)? onControllerInit;

  const BlockWidget({
    super.key,
    required this.block,
    this.isSelected = false,
    this.isMatched = false,
    this.onTap,
    this.onControllerInit,
  });

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _positionController;
  late Animation<double> _scaleAnimation;

  Offset? _targetOffset;
  Offset _currentOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Scale controller for squish effect
    _scaleController = AnimationController(
      vsync: this,
      duration: AnimationConstants.squishDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Position controller for movement
    _positionController = AnimationController(
      vsync: this,
      duration: AnimationConstants.swapDuration,
    );

    widget.onControllerInit?.call(_positionController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getBlockColor(widget.block.type);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: widget.isMatched
              ? _buildMatchedAnimation(color)
              : null,
        ),
      ),
    );
  }

  Widget _buildMatchedAnimation(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: AnimationConstants.fadeOutDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
```

## 4. Spring-based Position Animation

```dart
// core/utils/spring_animation_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../constants/animation_constants.dart';

class SpringAnimationHelper {
  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: AnimationConstants.swapDuration,
    );
  }

  static Animation<Offset> createPositionAnimation({
    required AnimationController controller,
    required Offset start,
    required Offset end,
    SpringDescription? spring,
  }) {
    final effectiveSpring = spring ?? AnimationConstants.swapSpring;

    return controller.drive(
      Tween<Offset>(begin: start, end: end),
    );
  }

  static void runSpringAnimation({
    required AnimationController controller,
    required double from,
    required double to,
    SpringDescription? spring,
    VoidCallback? onComplete,
  }) {
    final effectiveSpring = spring ?? AnimationConstants.swapSpring;

    final simulation = SpringSimulation(
      effectiveSpring,
      from,
      to,
      0, // velocity
    );

    controller.animateWith(simulation).then((_) {
      onComplete?.call();
    });
  }
}

// Custom Spring Simulation for custom physics
class CustomSpringSimulation extends Simulation {
  final SpringDescription spring;
  final double start;
  final double end;
  final double velocity;

  late final double _dampingRatio;
  late final double _angularFrequency;

  CustomSpringSimulation({
    required this.spring,
    required this.start,
    required this.end,
    this.velocity = 0,
  }) {
    _dampingRatio = spring.damping / (2 * spring.mass);
    _angularFrequency = spring.stiffness / spring.mass;
  }

  @override
  double x(double time) {
    final displacement = start - end;
    final dampedFactor = _dampingRatio * _angularFrequency;

    if (_dampingRatio < 1) {
      // Under-damped (bouncy)
      final omega = _angularFrequency * (1 - _dampingRatio * _dampingRatio);
      return end + displacement *
          (1 / omega) *
          (_dampingRatio * _angularFrequency * _e(-dampedFactor * time) *
              (1 - _dampedFactor / omega) +
              _e(-dampedFactor * time) * omega * _e(time * omega));
    }

    // Critically damped or over-damped
    return end + displacement * _e(-dampedFactor * time) * (1 + dampedFactor * time);
  }

  @override
  double dx(double time) {
    // Velocity calculation
    return 0; // Simplified
  }

  double _e(double x) => x.isFinite ? x.exp() : 0;

  @override
  bool isDone(double time) {
    return (x(time) - end).abs() < 0.001;
  }
}
```

## 5. Floating Score Animation

```dart
// presentation/widgets/floating_score.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/animation_constants.dart';

class FloatingScore extends StatefulWidget {
  final int score;
  final Offset position;
  final VoidCallback? onComplete;

  const FloatingScore({
    super.key,
    required this.score,
    required this.position,
    this.onComplete,
  });

  @override
  State<FloatingScore> createState() => _FloatingScoreState();
}

class _FloatingScoreState extends State<FloatingScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.floatUpDuration,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -50),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 70,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx,
          top: widget.position.dy + _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                '+${widget.score}',
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPositive,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 6. Score Display Animation (Rolling Numbers)

```dart
// presentation/widgets/score_display.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/animation_constants.dart';

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
      duration: AnimationConstants.scoreRollDuration,
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
    final startTime = DateTime.now();
    final duration = AnimationConstants.scoreRollDuration;

    _rollController.addListener(() {
      final progress = _rollController.value;
      final elapsed = Duration(
        milliseconds: (duration.inMilliseconds * progress).round(),
      );

      if (elapsed < duration) {
        final eased = Curves.easeOut.transform(progress);
        final current = from + ((to - from) * eased).round();
        setState(() {
          _displayedScore = current;
        });
      }
    });

    _rollController.forward(from: 0);
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main score
        Text(
          _displayedScore.toString(),
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -1.5,
          ),
        ),

        // High score
        Text(
          'Best: ${widget.highScore}',
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),

        // Multiplier (jika > 1)
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
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.accentWarning,
              ),
            ),
          ),
      ],
    );
  }
}
```

## 7. Grid Animation Optimizations

```dart
// presentation/widgets/game_grid.dart
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
    return RepaintBoundary(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: grid.rows * grid.cols,
        itemBuilder: (context, index) {
          final row = index ~/ grid.cols;
          final col = index % grid.cols;
          final block = grid.getBlock(row, col);

          if (block == null) {
            return const SizedBox.shrink();
          }

          final isSelected = selectedBlock?.id == block.id;

          return RepaintBoundary(
            child: BlockWidget(
              block: block,
              isSelected: isSelected,
              onTap: () => onBlockTap(block),
            ),
          );
        },
      ),
    );
  }
}
```

## 8. BlockWidget dengan Swipe Gestures

```dart
// presentation/widgets/block_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/block.dart';

enum BlockAnimationState {
  idle,
  dragging,
  matched,
  falling,
}

enum Direction { up, down, left, right }

class BlockWidget extends StatefulWidget {
  final Block block;
  final bool isSelected;
  final Function(Block, Direction)? onSwipe;
  final VoidCallback? onMatchComplete;

  const BlockWidget({
    super.key,
    required this.block,
    this.isSelected = false,
    this.onSwipe,
    this.onMatchComplete,
  });

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget>
    with TickerProviderStateMixin {
  late AnimationController _dragController;
  late AnimationController _matchController;
  late AnimationController _fallController;

  late Animation<double> _dragScale;
  late Animation<double> _dragRotation;
  late Animation<double> _matchGlow;
  late Animation<double> _matchSquish;
  late Animation<double> _matchFade;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  Direction? _swipeDirection;

  static const double _dragThreshold = 20.0;

  @override
  void initState() {
    super.initState();
    _initDragController();
    _initMatchController();
    _initFallController();
  }

  void _initDragController() {
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _dragScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _dragController,
        curve: Curves.elasticOut,
      ),
    );

    _dragRotation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _dragController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _initMatchController() {
    _matchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _matchGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.easeInOut,
    ));

    _matchSquish = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.easeIn,
    ));

    _matchFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _matchController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _initFallController() {
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    _matchController.dispose();
    _fallController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = Offset.zero;
    });
    _dragController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _updateSwipeDirection();
    });
  }

  void _updateSwipeDirection() {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dx.abs() > dy.abs()) {
      _swipeDirection = dx > 0 ? Direction.right : Direction.left;
    } else {
      _swipeDirection = dy > 0 ? Direction.down : Direction.up;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final distance = _dragOffset.distance;

    if (distance > _dragThreshold && _swipeDirection != null) {
      widget.onSwipe?.call(widget.block, _swipeDirection!);
    }

    _dragController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDragging = false;
          _dragOffset = Offset.zero;
          _swipeDirection = null;
        });
      }
    });
  }

  void playMatchAnimation() {
    _matchController.forward().then((_) {
      widget.onMatchComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getBlockColor(widget.block.type);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_dragController, _matchController]),
        builder: (context, child) {
          final scale = _dragScale.value * _matchSquish.value;
          final rotation = _swipeDirection == Direction.left
              ? -_dragRotation.value
              : _swipeDirection == Direction.right
                  ? _dragRotation.value
                  : 0.0;

          final offsetX = _isDragging ? _dragOffset.dx * 0.3 : 0.0;
          final offsetY = _isDragging ? _dragOffset.dy * 0.3 : 0.0;

          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Transform.scale(
              scale: scale.clamp(0.0, 2.0),
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                  opacity: _matchFade.value,
                  child: _buildBlock(color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlock(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.35),
            boxShadow: [
              if (widget.isSelected || _isDragging)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: _matchGlow.value * 15,
                spreadRadius: _matchGlow.value * 5,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(size * 0.18),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 9. Animation Performance Checklist

| Item | Target | Implementation |
|------|--------|----------------|
| Frame Rate | 60 FPS | Minimize rebuilds, use `const` |
| Repaints | Only changed cells | Use `RepaintBoundary` |
| Animations | Hardware accelerated | Use `AnimatedBuilder` |
| Memory | No leaks | Dispose controllers |
| Gesture | < 16ms response | Pre-calculate, lazy compute |

## 9. Haptic Feedback (Optional)

```dart
// core/utils/haptic_feedback.dart
import 'package:flutter/services.dart';

class HapticFeedbackHelper {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
```

---

**Referensi:**
- PRD Section 2: "Physics-based Animations (Spring Simulation)"
- Flutter Animation Documentation