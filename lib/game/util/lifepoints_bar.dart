import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

mixin LifePointsBar on BasicComponent {
  final _padding = 5.0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (this != playerOne) lifePointsBar(canvas);
  }

  void lifePointsBar(Canvas canvas) {
    canvas.drawLine(
        Offset(0, -_padding),
        Offset(width, -_padding),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.fill);

    var currentLifePoints = (lifePoints * width) / initialLifePoints;
    canvas.drawLine(
        Offset(0, -_padding),
        Offset(currentLifePoints, -_padding),
        Paint()
          ..color = () {
            if (currentLifePoints > (2 / 3) * width) return Colors.green;
            return (currentLifePoints > width / 3) ? Colors.orange : Colors.red;
          }()
          ..strokeWidth = 2
          ..style = PaintingStyle.fill);
  }
}
