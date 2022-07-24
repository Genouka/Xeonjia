import 'dart:math';

import 'package:flutter/material.dart';

enum Direction {
  down(0, 1),
  up(0, -1),
  right(1, 0),
  left(-1, 0);

  const Direction(this.dx, this.dy);
  final int dx;
  final int dy;
}

extension GetDirection on Direction {
  // Get opposite direction
  Direction get opposite => fromXY(-dx.toDouble(), -dy.toDouble());

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
