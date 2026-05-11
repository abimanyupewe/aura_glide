import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/block.dart';

enum BlockAnimationState {
  idle,
  dragging,
  matched,
  falling,
}

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

enum Direction { up, down, left, right }

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