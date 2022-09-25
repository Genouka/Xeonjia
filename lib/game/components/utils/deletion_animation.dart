import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Show an animation during respawn
mixin DeletionAnimation on Walker {
  TimerComponent? timer;

  /// Start respawn animation
  void deletionAnimation({required VoidCallback callback, double period = 1}) {
    isBeingDeleted = true;
    timer = TimerComponent(period: period, onTick: callback);
    gameRef.add(timer!);
  }

  @override
  void render(Canvas canvas) {
    if (isBeingDeleted && timer != null) {
      canvas.drawCircle(
          Offset(componentSize / 2, componentSize / 2),
          (1 - timer!.timer.progress) * 10,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    } else {
      super.render(canvas);
    }
  }
}
