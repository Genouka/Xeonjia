import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Show an animation during respawn
mixin RespawnAnimation on DynamicComponent {
  final _seconds = 1.0;
  double _remainingSeconds;
  bool get _show => isRespawning;

  // Start respawn animation
  void respawnAnimation() {
    isRespawning = true;
    _remainingSeconds = _seconds;
  }

  @override
  void update(double dt) {
    if (_show) {
      _remainingSeconds -= dt;
      if (_remainingSeconds <= 0) (this as CharacterComponent).respawn();
    } else {
      super.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_show) {
      prepareCanvas(canvas);
      _circleAnimation(canvas);
    } else {
      super.render(canvas);
    }
  }

  void _circleAnimation(Canvas canvas) {
    canvas.drawCircle(
        Offset(componentSize / 2, componentSize / 2),
        _remainingSeconds * 10,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }
}
