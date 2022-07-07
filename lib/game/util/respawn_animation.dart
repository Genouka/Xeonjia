import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Show an animation during respawn
mixin RespawnAnimation on DynamicComponent {
  late TimerComponent timer;

  // Start respawn animation
  void respawnAnimation() {
    isBeingDeleted = true;
    timer = TimerComponent(period: 1, onTick: respawn);
    game!.add(timer);
  }

  @override
  void render(Canvas canvas) {
    if (isBeingDeleted) {
      canvas.drawCircle(
          Offset(componentSize / 2, componentSize / 2),
          (1 - timer.timer.current) * 10,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    } else {
      super.render(canvas);
    }
  }
}
