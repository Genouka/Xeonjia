import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

class BackgroundComponent extends SpriteComponent {
  BackgroundComponent(double width, double height, Sprite sprite)
      : super(sprite: sprite, size: Vector2(width, height));

  @override
  int get priority => -999;

  @override
  void onGameResize(Vector2 size) {
    width = game!.map.width * componentSize;
    height = game!.map.height * componentSize;
    super.onGameResize(size);
  }
}
