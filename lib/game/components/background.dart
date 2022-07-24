import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

class BackgroundComponent extends PositionComponent
    with HasGameRef<XeonjiaGame> {
  @override
  final int priority = -999;

  final Paint paint = Paint()..color = const Color(0xFFE1F5FE);

  @override
  void render(Canvas canvas) =>
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

  @override
  void onGameResize(Vector2 size) {
    width = gameRef.map.width * componentSize;
    height = gameRef.map.height * componentSize;
    super.onGameResize(size);
  }
}
