import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

class BackgroundComponent extends SpriteComponent with HasGameRef<XeonjiaGame> {
  BackgroundComponent()
      : super(sprite: Sprite(Flame.images.fromCache('background.png'))) {
    priority = -999;
  }

  @override
  void onGameResize(Vector2 size) {
    width = gameRef.map.width * componentSize;
    height = gameRef.map.height * componentSize;
    super.onGameResize(size);
  }
}
