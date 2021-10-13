import 'dart:math';

import 'package:flutter/material.dart';

enum Direction { down, up, right, left }

extension GetDirection on Direction {
  double get dx =>
      this == Direction.right ? 1 : (this == Direction.left ? -1 : 0);
  double get dy => this == Direction.down ? 1 : (this == Direction.up ? -1 : 0);

  // Get opposite direction
  Direction get opposite => fromXY(-dx, -dy);

  // Get a random direction
  static Direction get random => Direction.values[Random().nextInt(4)];

  // Get direction from different sources
  static Direction fromInt(int value) => Direction.values[value];
  static Direction fromXY(double x, double y) => fromOffset(Offset(x, y));
  static Direction fromOffset(Offset offset) =>
      (offset.dx.abs() >= offset.dy.abs())
          ? offset.dx >= 0
              ? Direction.right
              : Direction.left
          : offset.dy >= 0
              ? Direction.down
              : Direction.up;
}
