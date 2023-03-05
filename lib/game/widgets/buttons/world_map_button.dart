import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/map_controller.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

/// Button that opens the world map
class WorldMapButton extends TextBoxComponent
    with HasGameRef<XeonjiaGame>, Tappable {
  WorldMapButton() : super(size: Vector2.all(1), align: Anchor.center) {
    positionType = PositionType.viewport;
    priority = 10000;
  }

  List<String> texts = [
    'Open local map'.i18n.toUpperCase(),
    'Open world map'.i18n.toUpperCase(),
  ];

  @override
  void onMount() {
    textRenderer =
        TextPaint(style: Theme.of(gameRef.buildContext!).textTheme.labelLarge);
    return super.onMount();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(min(320, gameRef.canvasSize.x / 1.8), 36);
    position = Vector2(6, gameRef.canvasSize.y - this.size.y - 6);
    // Workaround to force align = center again
    text = text + ' ';
    text = text.trim();
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (!gameRef.worldMapDisabled) gameRef.worldMap();
    return true;
  }

  @override
  void update(double dt) {
    text = gameRef.worldMapEnabled ? texts.first : texts.last;
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    if (gameRef.worldMapDisabled) return;
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(30));
    c.drawRRect(rect, Paint()..color = Colors.grey.shade800.withOpacity(0.7));
    super.render(c);
  }
}
