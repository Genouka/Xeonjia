import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Button that opens the world map
class WorldMapButton extends TextBoxComponent
    with HasGameReference<XeonjiaGame>, TapCallbacks {
  WorldMapButton() : super(align: Anchor.center) {
    priority = 10000;
  }

  List<String> texts = [
    'Open local map'.i18n.toUpperCase(),
    'Open world map'.i18n.toUpperCase(),
  ];

  @override
  void onMount() {
    textRenderer = TextPaint(
      style: Theme.of(game.buildContext!).textTheme.labelLarge,
    );
    return super.onMount();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(min(320, game.canvasSize.x / 1.8), 60);
    position = Vector2(6, game.canvasSize.y - this.size.y);
    // Workaround to force align = center again
    text = text + ' ';
    text = text.trim();
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (!game.worldMapDisabled) game.worldMap();
    return true;
  }

  @override
  void update(double dt) {
    text = game.worldMapEnabled ? texts.first : texts.last;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (game.worldMapDisabled) return;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(30),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.grey.shade800.withAlpha((255.0 * 0.7).round()),
    );
    super.render(canvas);
  }
}
