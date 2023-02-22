import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

/// Box with the number of remaining moves
class RemainingMovesBox extends TextBoxComponent with HasGameRef<XeonjiaGame> {
  RemainingMovesBox()
      : super(
          size: Vector2.all(1),
          align: Anchor.center,
        ) {
    positionType = PositionType.viewport;
    priority = 1000;
  }

  @override
  void onMount() {
    textRenderer =
        TextPaint(style: Theme.of(gameRef.buildContext!).textTheme.labelLarge);
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
    this.size = Vector2(min(320, gameRef.canvasSize.x / 2.2), 36);
    position = Vector2(6, gameRef.miniMapEnabled ? 6 : 46);
    // Workaround to force align = center again
    text = text + ' ';
    text = text.trim();
  }

  @override
  void update(double dt) {
    text = (gameRef.playerOne?.isMyTurn ?? false)
        ? texts[gameRef.remainingMoves]!
        : texts[0]!;
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    if (gameRef.enemies == 0 || gameRef.worldMapEnabled) return;
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(30));
    c.drawRRect(rect, Paint()..color = Colors.grey.shade800.withOpacity(0.7));
    super.render(c);
  }
}
