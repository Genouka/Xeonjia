import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/static.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

/// Hide / Show hints
class HideHintsButton extends TextBoxComponent
    with HasGameRef<XeonjiaGame>, Tappable {
  HideHintsButton() : super(size: Vector2.all(1), align: Anchor.center) {
    positionType = PositionType.viewport;
    priority = 10000;
  }

  List<String> texts = [
    'Show hints'.i18n.toUpperCase(),
    'Hide hints'.i18n.toUpperCase(),
  ];

  bool get disabled =>
      (gameRef.overlays.isActive('mapNameBox') && !gameRef.miniMapEnabled) ||
      gameRef.worldMapEnabled ||
      gameRef.children.where((c) => c is StaticComponent && c.hideable).isEmpty;

  @override
  void onMount() {
    textRenderer =
        TextPaint(style: Theme.of(gameRef.buildContext!).textTheme.labelLarge);
    return super.onMount();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(min(320, gameRef.canvasSize.x / 2.2), 36);
    position = Vector2(6, 46);
    // Workaround to force align = center again
    text = text + ' ';
    text = text.trim();
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (!disabled) gameRef.hideHints = !gameRef.hideHints;
    return true;
  }

  @override
  void update(double dt) {
    text = gameRef.hideHints ? texts.first : texts.last;
    super.update(dt);
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
