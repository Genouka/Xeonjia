import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Box with the number of remaining moves
class RemainingMovesBox extends TextBoxComponent
    with HasGameReference<XeonjiaGame> {
  RemainingMovesBox() : super(size: Vector2(320, 36), align: Anchor.center) {
    priority = 1000;
  }

  @override
  void onMount() {
    textRenderer = TextPaint(
      style: Theme.of(game.buildContext!).textTheme.labelLarge,
    );
    super.onMount();
  }

  // To avoid calling .i18n every update()
  final Map<int, String> texts = {
    0: 'Wait'.i18n.toUpperCase(),
    1: '1 move'.i18n.toUpperCase(),
    2: '2 moves'.i18n.toUpperCase(),
    3: '3 moves'.i18n.toUpperCase(),
  };

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(min(320, game.canvasSize.x / 2.2), 36);
    position = Vector2(6, game.miniMapEnabled ? 6 : 46);
    // Workaround to force align = center again
    text = text + ' ';
    text = text.trim();
  }

  @override
  void update(double dt) {
    text = (game.user?.isMyTurn ?? false)
        ? texts[game.remainingMoves]!
        : texts[0]!;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (game.enemies == 0 || game.worldMapEnabled) return;
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
