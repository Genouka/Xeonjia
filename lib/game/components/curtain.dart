import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Black curtain shown while changing room
class CurtainComponent extends PositionComponent with HasGameRef<XeonjiaGame> {
  double _opacity = 1;
  bool get done => _opacity == 0;
  void start() => _opacity = 1;

  @override
  void render(Canvas canvas) {
    if (!done) {
      canvas.drawPaint(
          Paint()..color = const Color(0xff000000).withOpacity(_opacity));
    }
  }

  @override
  void update(double dt) {
    if (!done) _opacity = max(0, _opacity - dt * 3);
  }

  @override
  int priority = 10000000;
}
