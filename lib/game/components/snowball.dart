import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Shot created by [SnowBallWeapon]
class SnowballComponent extends BasicComponent with Walker {
  SnowballComponent(
      Point startingPosition, this.father, this.direction, this.atk)
      : super(
            null,
            Point(startingPosition.x / componentSize,
                startingPosition.y / componentSize),
            {});

  @override
  BasicComponent? father;

  @override
  String? atlasAsset = 'weapons.xfa';

  @override
  String? name = 'snowball';

  @override
  Sprite getSpriteFromAtlas() =>
      atlas.getSprite('${name!}-${direction!.index}');

  @override
  Direction? direction;

  @override
  final double atk;

  @override
  double get speed => Walker.defaultSpeed * 1.5;

  @override
  bool isSolid({Walker? otherComponent}) => false;

  @override
  bool isFlying() => true;

  @override
  int get priority => 125;

  @override
  void isMoving() {
    if (father!.distance(this) > componentSize * 2 && direction != null) {
      gameRef.updateCamera(x - direction!.dx * 2 * componentSize,
          y - direction!.dy * 2 * componentSize);
    }
  }

  @override
  void onCollision(BasicComponent? collidedComponent,
      [bool wasStationary = false]) {
    if (isBeingDeleted) return;
    x += direction!.dx * componentSize / 2;
    y += direction!.dy * componentSize / 2;
    stop();
    gameRef.playSound(Sfx.snowball);
    isBeingDeleted = true;
    animation = atlas.getAnimation('${name}_explosion')
      ..onComplete = () {
        if (gameRef.activePlayer != null &&
            !gameRef.playerOne!.isBeingDeleted) {
          gameRef.camera.moveTo(Vector2(
              gameRef.moveCamera(
                  gameRef.size.x, gameRef.map.width, gameRef.activePlayer!.x),
              gameRef.moveCamera(gameRef.size.y, gameRef.map.height,
                  gameRef.activePlayer!.y)));
        }
        hide();
        // Wait 0.5 seconds before next npc move
        gameRef.add(TimerComponent(
            period: (father as Walker).teamId != 0 ? 0.5 : 0,
            onTick: () {
              gameRef.useMove(father as Walker);
              delete();
            }));
      };
    if (collidedComponent?.teamId != father!.teamId) {
      collidedComponent?.hpDifference(-atk, cause: father);
    }
  }
}
