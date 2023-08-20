import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// TextBox shown at the beginning and end of a battle
class BattleTextBox extends PositionComponent with HasGameRef<XeonjiaGame> {
  BattleTextBox(this.text) {
    positionType = PositionType.viewport;
    priority = 1000;
    anchor = Anchor.center;
  }

  final String text;
  final TextPaint textPaint =
      TextPaint(style: TextStyle(fontSize: 64, fontFamily: settings.font));

  /// Seconds to open and close the box (total duration = animationDuration * 2)
  double animationDuration = 0.4;

  /// Seconds the box stays open
  double stayOpenFor = 1.5;

  /// Seconds elapsed since the start
  double elapsed = 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    height = 84;
    width = size.x;
    position = Vector2(size.x / 2, size.y / 2);
  }

  @override
  void update(double dt) {
    if (elapsed > animationDuration && (stayOpenFor -= dt) > 0) return;
    if ((elapsed += dt) > 2 * animationDuration) gameRef.remove(this);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    double currentWidth = stayOpenFor >= 0
        ? width * elapsed / animationDuration
        : width * (2 - elapsed / animationDuration);
    canvas.drawRect(
        Rect.fromLTWH((width - currentWidth) / 2, 0, currentWidth, height),
        Paint()..color = Colors.grey.shade800.withOpacity(0.7));
    if (currentWidth > width / 3) {
      textPaint.render(
          canvas, text, Vector2(gameRef.size.x / 2, height / 2 - 4),
          anchor: Anchor.center);
    }
  }
}
