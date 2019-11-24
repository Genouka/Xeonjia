import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Shot created by SnowBallWeapon
class SnowballComponent extends DynamicComponent {
  // Shot direction
  final int _direction;

  final double atk;
  BasicComponent father;
  double distancePerFrame = defaultDistancePerFrame * 2;

  SnowballComponent(startX, startY, this._direction, this.father, this.atk)
      : super(startX, startY, 'snowball.png') {
    switch (_direction) {
      case 1:
        directionX = 0;
        directionY = 1;
        break;
      case 2:
        directionX = 0;
        directionY = -1;
        break;
      case 3:
        directionX = 1;
        directionY = 0;
        break;
      case 4:
        directionX = -1;
        directionY = 0;
        break;
      default:
        break;
    }
  }

  @override
  bool isSolid({DynamicComponent otherComponent}) => false;

  @override
  bool isFlying() => true;

  @override
  int priority() => 5;

  @override
  void updateSprite() {
    // It doesn't do anything because the sprite remains the same
  }

  @override
  void onCollision() {
    if (collidedComponent != father) {
      collidedComponent?.lifePointsDifference(-atk, cause: this.father);
      componentDeleted();
    }
  }
}
