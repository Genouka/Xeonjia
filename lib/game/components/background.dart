import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Ice floor
class BackgroundComponent extends PositionComponent
    with HasGameReference<XeonjiaGame> {
  @override
  final int priority = -999;
  late ui.Image img;
  late final Paint _paint;

  @override
  FutureOr<void> onLoad() async {
    ByteData bd = await rootBundle.load('assets/images/background.png');
    ui.Codec codec = await ui.instantiateImageCodec(Uint8List.view(bd.buffer));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    img = frameInfo.image;
    _paint = Paint()
      ..shader = ui.ImageShader(
        img,
        TileMode.repeated,
        TileMode.repeated,
        Matrix4.identity().storage,
      )
      ..filterQuality = FilterQuality.none;
  }

  @override
  void render(Canvas canvas) {
    if (game.worldMapEnabled) return;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width * game.miniMapZoom, height * game.miniMapZoom),
      _paint,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    width = game.map.width * componentSize;
    height = game.map.height * componentSize;
    super.onGameResize(size);
  }
}
