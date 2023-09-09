import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Ice floor
class BackgroundComponent extends PositionComponent
    with HasGameRef<XeonjiaGame> {
  @override
  final int priority = -999;
  late ui.Image img;

  @override
  FutureOr<void> onLoad() async {
    ByteData bd = await rootBundle.load('assets/images/background.png');
    ui.Codec codec = await ui.instantiateImageCodec(Uint8List.view(bd.buffer));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    img = frameInfo.image;
  }

  @override
  void render(Canvas canvas) {
    gameRef.worldMapEnabled
        ? null
        : paintImage(
            canvas: canvas,
            rect: Rect.fromLTWH(0, 0, width * gameRef.miniMapZoom,
                height * gameRef.miniMapZoom),
            image: img,
            repeat: ImageRepeat.repeat,
            filterQuality: FilterQuality.none,
          );
  }

  @override
  void onGameResize(Vector2 size) {
    width = gameRef.map.width * componentSize;
    height = gameRef.map.height * componentSize;
    super.onGameResize(size);
  }
}
