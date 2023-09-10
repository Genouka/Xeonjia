import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Show an animation during deletion
mixin DeletionAnimation on Walker {
  TimerComponent? timer;

  /// Start deletion animation
  void deletionAnimation({required VoidCallback callback}) {
    isBeingDeleted = true;
    timer = TimerComponent(period: 1.5, onTick: callback);
    gameRef.add(timer!);
  }

  @override
  void render(Canvas canvas) {
    if (isBeingDeleted && timer != null) {
      setOpacity(max(0, 1 - timer!.timer.progress - 0.5));
      super.render(canvas);
      canvas.drawCircle(
          Offset(componentSize / 2, componentSize / 2),
          max(0, 1 - timer!.timer.progress - 0.5) * 45,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke);
    } else {
      super.render(canvas);
    }
  }

  @override
  void respawn(XeonjiaGame gameRef) {
    makeOpaque();
    super.respawn(gameRef);
  }
}
