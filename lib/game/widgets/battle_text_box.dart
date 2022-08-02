import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// TextBox shown at the beginning and end of a battle
class BattleTextBox extends TextComponent with HasGameRef<XeonjiaGame> {
  BattleTextBox(Vector2 size, String text)
      : super(
          text: text,
          anchor: Anchor.center,
          position: size / 2,
          size: size,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 64,
              fontFamily: settings.useSystemFont ? null : 'dd5x7',
              color: BasicPalette.white.color,
            ),
          ),
        ) {
    positionType = PositionType.viewport;
    priority = 1000;
  }

  // Seconds to open and close the box
  double animationDuration = 0.5;

  // Seconds the box stays open
  double stayOpenFor = 1.5;

  // Seconds elapsed since the start
  double elapsed = 0;

  @override
  void update(double dt) {
    if (elapsed > animationDuration && (stayOpenFor -= dt) > 0) return;
    if ((elapsed += dt) > 2 * animationDuration) gameRef.remove(this);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    double currentWidth = elapsed < animationDuration
        ? width * elapsed * 4
        : width * (1 - elapsed) * 4;
    final rect =
        Rect.fromLTWH(width / 2 - currentWidth, -10, 2 * currentWidth, 84);
    canvas.drawRect(
        rect, Paint()..color = Colors.grey.shade800.withOpacity(0.7));
    if (currentWidth > width / 2) super.render(canvas);
  }
}
