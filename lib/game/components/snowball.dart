import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Shot created by SnowBallWeapon
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
  Sprite getSpriteFromAtlas() => atlas.getSprite(name!);

  @override
  Direction? direction;

  @override
  final double atk;

  @override
  double get speed => defaultSpeed * 2;

  @override
  bool isSolid({Walker? otherComponent}) => false;

  @override
  bool isFlying() => true;

  @override
  int get priority => 125;

  @override
  void onCollision(BasicComponent? collidedComponent,
      [bool wasStationary = false]) {
    if (isBeingDeleted) return;
    x += direction!.dx * componentSize / 2;
    y += direction!.dy * componentSize / 2;
    stop();
    gameRef.playSound(Sfx.snowball);
    isBeingDeleted = true;
    animation = atlas.getAnimation('${name}_explosion')..onComplete = delete;
    if (gameRef.config.friendlyFire ||
        collidedComponent?.teamId != father!.teamId) {
      collidedComponent?.lifePointsDifference(-atk, cause: father);
    }
  }
}
