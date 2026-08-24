import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Hide / Show hints
class HideHintsButton extends TextBoxComponent
    with HasGameReference<XeonjiaGame>, TapCallbacks {
  HideHintsButton() : super(align: Anchor.center) {
    priority = 10000;
  }

  List<String> texts = [
    'Show hints'.i18n.toUpperCase(),
    'Hide hints'.i18n.toUpperCase(),
  ];

  bool get disabled =>
      (game.overlays.isActive('mapNameBox') && !game.miniMapEnabled) ||
      game.worldMapEnabled ||
      game.world.children
          .where((c) => c is StaticComponent && c.hideable)
          .isEmpty;

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
    this.size = Vector2(min(320, game.canvasSize.x / 2.2), 36);
    position = Vector2(6, 46);
    // Workaround to force align = center again
    text = text + ' ';
    text = text.trim();
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (!disabled) game.hideHints = !game.hideHints;
    return true;
  }

  @override
  void update(double dt) {
    text = game.hideHints ? texts.first : texts.last;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (disabled) return;
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
