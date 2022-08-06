import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

// It opens the world map
class WorldMapButton extends TextBoxComponent
    with HasGameRef<XeonjiaGame>, Tappable {
  WorldMapButton() : super(size: Vector2.all(1), align: Anchor.center) {
    positionType = PositionType.viewport;
    priority = 1000;
    text = 'World map'.i18n.toUpperCase();
  }

  @override
  Future<void> onLoad() {
    textRenderer =
        TextPaint(style: Theme.of(gameRef.buildContext!).textTheme.button);
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(min(320, gameRef.canvasSize.x / 2.2), 36);
    position = Vector2(gameRef.canvasSize.x - this.size.x - 6, 46);
  }

  bool get disabled =>
      !gameRef.miniMapEnabled || gameRef.worldMapEnabled || gameRef.enemies > 0;

  @override
  bool onTapUp(TapUpInfo info) {
    if (!disabled) gameRef.worldMap();
    return true;
  }

  @override
  void render(Canvas c) {
    if (disabled) return;
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(30));
    c.drawRRect(rect, Paint()..color = Colors.grey.shade800.withOpacity(0.7));
    super.render(c);
  }
}
