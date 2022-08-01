import 'dart:ui';

import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/utils/lifepoints_bar.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/weapons.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends BasicComponent with Walker, LifePointsBar {
  SlitherCpuComponent(tile)
      : _updatePeriod = double.parse(tile.properties['updatePeriod'] ?? '0.5'),
        super.fromTile(tile) {
    _timeToNextMove = _updatePeriod;
    weaponList = [PunchWeapon(level: level)];
  }

  @override
  int teamId = -2;

  @override
  String? atlasAsset = 'monsters.xfa';

  @override
  String? name = 'green';

  // Frequency of movements (CPU only)
  final double _updatePeriod;
  late double _timeToNextMove;

  @override
  void lifePointsDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if (cause?.isPlayerOne ?? false) {
      super.lifePointsDifference(difference, cause: cause!, poison: poison);
    }
  }

  @override
  void update(double dt) {
    if (gameRef.isNotPaused && isMyTurn && (_timeToNextMove -= dt) < 0) {
      bool near = false;
      Direction newOrientation = orientation;
      if (gameRef.playerOne!.x == x) {
        newOrientation =
            gameRef.playerOne!.y > y ? Direction.down : Direction.up;
        near = true;
      } else if (gameRef.playerOne!.y == y) {
        newOrientation =
            gameRef.playerOne!.x > x ? Direction.right : Direction.left;
        near = true;
      }
      if (componentInFront(newOrientation) == gameRef.playerOne) {
        updateOrientation(newOrientation);
        shoot();
      } else {
        if (!near) newOrientation = GetDirection.random;
        if (componentInFront(newOrientation)?.isSolid(otherComponent: this) ??
            false) {
          newOrientation = orientation.opposite;
          if (componentInFront(newOrientation)?.isSolid(otherComponent: this) ??
              false) {
            newOrientation = GetDirection.random;
            if (componentInFront(newOrientation)
                    ?.isSolid(otherComponent: this) ??
                false) {
              gameRef.useMove();
            }
          }
          updateDirection(newOrientation);
        } else {
          updateDirection(newOrientation);
        }
      }
      _timeToNextMove = _updatePeriod;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, gameRef.characterOffset));
  }
}
