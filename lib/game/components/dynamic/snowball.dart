import 'dart:math';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/animated_component.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Shot created by SnowBallWeapon
class SnowballComponent extends DynamicComponent {
  @override
  BasicComponent father;

  @override
  final Direction direction;

  @override
  final double atk;

  @override
  double distancePerFrame = defaultDistancePerFrame * 2;

  SnowballComponent(
      Point startingPosition, this.father, this.direction, this.atk)
      : super(startingPosition, 'snowball.png');

  @override
  bool isSolid({DynamicComponent otherComponent}) => false;

  @override
  bool isFlying() => true;

  @override
  int priority() => 5;

  @override
  void onCollision() {
    Explosion(this, stepTime: 0.02);
    delete();
    if (game.friendlyFire || collidedComponent.teamId != father.teamId) {
      collidedComponent?.lifePointsDifference(-atk, cause: father);
    }
  }
}
