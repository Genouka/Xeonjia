import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/animated_component.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Shot created by SnowBallWeapon
class SnowballComponent extends DynamicComponent {
  // Shot direction
  final int _direction;

  @override
  final double atk;

  @override
  BasicComponent father;

  @override
  double distancePerFrame = defaultDistancePerFrame * 2;

  SnowballComponent(startX, startY, this._direction, this.father, this.atk)
      : super(startX, startY, 'snowball.png') {
    List directionXY = directionToXY(_direction);
    directionX = directionXY.first;
    directionY = directionXY.last;
  }

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
