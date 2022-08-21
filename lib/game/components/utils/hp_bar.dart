import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/utils/extensions.dart';

// Draw a health points bar near the component
// It is shown only for 2 seconds after healthPointsDifference
mixin HPBar on BasicComponent {
  final _padding = 5.0;
  final _seconds = 2.0;
  double _remainingSeconds = -1;
  bool get _show => !isPlayerOne && hp != maxHP && _remainingSeconds >= 0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_show) _healthPointsBar(canvas);
  }

  @override
  void update(double dt) {
    if (_show) _remainingSeconds -= dt;
    super.update(dt);
  }

  void _healthPointsBar(Canvas canvas) {
    canvas.drawLine(
        Offset(0, -_padding),
        Offset(width, -_padding),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.fill);

    var currentHP = (hp * width) / maxHP;
    canvas.drawLine(
        Offset(0, -_padding),
        Offset(currentHP, -_padding),
        Paint()
          ..color = MyColors.healthPointsColor(currentHP / width)
          ..strokeWidth = 2
          ..style = PaintingStyle.fill);
  }

  void _showBar() => _remainingSeconds = _seconds;

  @override
  void hpDifference(double difference, {cause, poison = 0.0}) {
    if (difference != 0) _showBar();
    super.hpDifference(difference, cause: cause, poison: poison);
  }
}
