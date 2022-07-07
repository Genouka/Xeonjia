import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

class BackgroundComponent extends SpriteComponent {
  BackgroundComponent()
      : super(sprite: Sprite(Flame.images.fromCache('background.png'))) {
    priority = -999;
  }

  @override
  void onGameResize(Vector2 size) {
    width = game!.map.width * componentSize;
    height = game!.map.height * componentSize;
    super.onGameResize(size);
  }
}
