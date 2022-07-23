import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/sfx.dart';

// Shot created by SnowBallWeapon
class SnowballComponent extends DynamicComponent {
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
  bool isSolid({DynamicComponent? otherComponent}) => false;

  @override
  bool isFlying() => true;

  @override
  int get priority => 125;

  @override
  void onCollision(BasicComponent? collidedComponent) {
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
