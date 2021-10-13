import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/rendering.dart';
import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

class BackgroundComponent extends SpriteComponent {
  BackgroundComponent(double width, double height, Sprite sprite)
      : super.fromSprite(width, height, sprite);

  @override
  int priority() => -999;

  @override
  // ignore: avoid_renaming_method_parameters
  void resize(Size _) {
    width = game.map.width * componentSize;
    height = game.map.height * componentSize;
  }

  @override
  void render(Canvas canvas) {
    if (game?.miniMapEnabled ?? false) {
      canvas.scale(
          (componentSize * game.miniMapZoom).gridAligned / componentSize);
    }
    super.render(canvas);
  }
}
