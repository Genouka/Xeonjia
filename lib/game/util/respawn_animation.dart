import 'package:flame/components/timer_component.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Show an animation during respawn
mixin RespawnAnimation on DynamicComponent {
  Timer timer;

  // Start respawn animation
  void respawnAnimation() {
    isBeingDeleted = true;
    timer = Timer(1, callback: respawn, repeat: false);
    game.addLater(TimerComponent(timer..start()));
  }

  @override
  void render(Canvas canvas) {
    if (isBeingDeleted) {
      prepareCanvas(canvas);
      canvas.drawCircle(
          Offset(componentSize / 2, componentSize / 2),
          (1 - timer.current) * 10,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    } else {
      super.render(canvas);
    }
  }
}
