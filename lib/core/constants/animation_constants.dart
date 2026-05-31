import 'package:flutter/physics.dart';

class AnimationConstants {
  AnimationConstants._();

  static const SpringDescription swapSpring = SpringDescription(
    mass: 0.8,
    stiffness: 400.0,
    damping: 15.0,
  );

  static const SpringDescription gravitySpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  static const SpringDescription squishSpring = SpringDescription(
    mass: 0.8,
    stiffness: 600.0,
    damping: 12.0,
  );

  static const SpringDescription floatSpring = SpringDescription(
    mass: 0.5,
    stiffness: 100.0,
    damping: 12.0,
  );

  static const Duration swapDuration = Duration(milliseconds: 200);
  static const Duration gravityDuration = Duration(milliseconds: 250);
  static const Duration squishDuration = Duration(milliseconds: 100);
  static const Duration fadeOutDuration = Duration(milliseconds: 150);
  static const Duration floatUpDuration = Duration(milliseconds: 600);
  static const Duration scoreRollDuration = Duration(milliseconds: 300);
}