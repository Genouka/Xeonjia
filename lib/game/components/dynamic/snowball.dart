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
            {'image': 'snowball.png'});

  @override
  BasicComponent? father;

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
    game!.playSound(Sfx.snowball);
    isBeingDeleted = true;
    animation = SpriteAnimation.fromFrameData(
        game!.images.fromCache(image),
        SpriteAnimationData.sequenced(
          amount: 4,
          texturePosition: Vector2(16, 16.0 * father!.teamId),
          textureSize: Vector2.all(16),
          stepTime: 0.02,
          loop: false,
        ))
      ..onComplete = delete;
    if (game!.config.friendlyFire ||
        collidedComponent?.teamId != father!.teamId) {
      collidedComponent?.lifePointsDifference(-atk, cause: father);
    }
  }
}
