import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// Box with the number of remaining moves
class RemainingMovesBox extends TextBoxComponent with HasGameRef<XeonjiaGame> {
  RemainingMovesBox()
      : super(
          position: Vector2(6, 46),
          size: Vector2.all(1),
          align: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 32,
              fontFamily: settings.useSystemFont ? null : 'dd5x7',
              color: BasicPalette.white.color,
            ),
          ),
        );

  @override
  PositionType positionType = PositionType.viewport;

  @override
  int priority = 1000;

  // To avoid calling .i18n every update()
  final Map<int, String> texts = {
    1: '1 move'.i18n,
    2: '2 moves'.i18n,
    3: '3 moves'.i18n,
  };

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(min(320, gameRef.canvasSize.x / 2.2), 36);
  }

  @override
  void update(double dt) {
    text =
        gameRef.playerOne!.isMyTurn ? texts[gameRef.remainingMoves]! : 'wait';
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    if (gameRef.enemies == 0) return;
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(30));
    c.drawRRect(rect, Paint()..color = Colors.grey.shade800.withOpacity(0.7));
    super.render(c);
  }
}
