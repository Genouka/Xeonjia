import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Draw a health points bar near the component
/// It is shown only for 2 seconds after healthPointsDifference
mixin HPBar on Walker {
  final _padding = 5.0;
  bool get _show =>
      gameRef.inBattle &&
      ((teamId != 0 || !isMyTurn) && hp != maxHP && hp != 0);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_show) _healthPointsBar(canvas);
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
}
