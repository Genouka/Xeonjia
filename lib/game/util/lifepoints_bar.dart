import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Draw a life point bar near the component
// It is shown only for 2 seconds after lifePointsDifference
mixin LifePointsBar on BasicComponent {
  final _padding = 5.0;
  final _seconds = 2.0;
  double _remainingSeconds;
  bool get _show => this != playerOne && (_remainingSeconds ?? -1) >= 0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_show) _lifePointsBar(canvas);
  }

  @override
  void update(double dt) {
    if (_show) _remainingSeconds -= dt;
    super.update(dt);
  }

  void _lifePointsBar(Canvas canvas) {
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

  void _showBar() {
    _remainingSeconds = _seconds;
  }

  @override
  void lifePointsDifference(double difference, {cause, poison = 0.0}) {
    _showBar();
    super.lifePointsDifference(difference, cause: cause, poison: poison);
  }
}
