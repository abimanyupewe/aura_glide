import 'package:flutter/physics.dart';

class AnimationConstants {
  AnimationConstants._();

  static const SpringDescription swapSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  static const SpringDescription gravitySpring = SpringDescription(
    mass: 1.5,
    stiffness: 200.0,
    damping: 25.0,
  );

  static const SpringDescription squishSpring = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 15.0,
  );

  static const SpringDescription floatSpring = SpringDescription(
    mass: 0.5,
    stiffness: 100.0,
    damping: 12.0,
  );

  static const Duration swapDuration = Duration(milliseconds: 300);
  static const Duration gravityDuration = Duration(milliseconds: 400);
  static const Duration squishDuration = Duration(milliseconds: 150);
  static const Duration fadeOutDuration = Duration(milliseconds: 200);
  static const Duration floatUpDuration = Duration(milliseconds: 800);
  static const Duration scoreRollDuration = Duration(milliseconds: 500);
}