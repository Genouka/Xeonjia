import 'package:flame/components/timer_component.dart';
import 'package:flame/time.dart';

import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Manage movements and shots (NPC)
class NpcController {
  // Pattern defined in tile.properties['movementPattern']
  final List<Direction> _movementPattern = [];
  int _movementPatternIndex = 0;
  Direction get _nextDirection => _movementPattern[_movementPatternIndex];
  bool get _hasMovements => _movementPattern.isNotEmpty;

  // Pattern defined in tile.properties['shotPattern']
  final List<_CpuShot> _shotPattern = [];
  final int _shotPatternIndex = 0;
  _CpuShot get _nextShot => _shotPattern[_shotPatternIndex];
  bool get _hasShots => _shotPattern.isNotEmpty;

  // Time until next operations
  double _timeToNextMove = 0.1;
  double _timeToNextShoot = 0.2;

  // Read and import patterns
  // movementPatternString: is a list of: direction
  // shotPatternString:     is a list of: direction | frequency
  NpcController(String movementPatternString, String shotPatternString) {
    if (movementPatternString != null) {
      movementPatternString.split(',').forEach((m) {
        _movementPattern.add(GetDirection.fromInt(int.parse(m)));
      });
    }
    if (shotPatternString != null) {
      shotPatternString.split(',').forEach((s) {
        _shotPattern.add(_CpuShot(
            GetDirection.fromInt(int.parse(s.split('|').first)),
            double.parse(s.split('|').last)));
      });
    }
  }

  // Increase _movementPatternIndex
  void updateMovement() {
    if (++_movementPatternIndex >= _movementPattern.length) {
      _movementPatternIndex = 0;
    }
  }

  // Increase _shotPatternIndex
  //void _updateShot() {
  //  if (++_shotPatternIndex >= _shotPattern.length) _shotPatternIndex = 0;
  //}

  // Move
  void move(CharacterComponent npc, double t) {
    if (!npc.quiet) {
      if (_hasMovements && npc.isStationary) {
        game.addLater(TimerComponent(Timer(
          0.5,
          callback: () => npc.updateDirection(_nextDirection, animated: false),
          repeat: false,
        )..start()));
      } else if ((_timeToNextMove -= t) < 0 && npc.randomDouble() > 0.2) {
        npc.updateDirection(GetDirection.random, animated: false);
        _timeToNextMove = 0.1;
      }
    }
  }

  // Shoot
  void shoot(CharacterComponent npc, double t) {
    if (!npc.friendly && (_timeToNextShoot -= t) < 0) {
      if (_hasShots) {
        npc.updateOrientation(_nextShot.direction);
        _timeToNextShoot = _nextShot.frequency;
      } else {
        _timeToNextShoot = 0.2;
      }
      if (game.playerOne.x == npc.x) {
        npc.updateOrientation(
            game.playerOne.y > npc.y ? Direction.down : Direction.up);
      } else if (game.playerOne.y == npc.y) {
        npc.updateOrientation(
            game.playerOne.x > npc.x ? Direction.right : Direction.left);
      }
      if (npc.randomDouble() > 0.1) npc.nextWeapon();
      if (npc.randomDouble() > 0.1) npc.shoot();
    }
  }
}

class _CpuShot {
  Direction direction;
  double frequency;
  _CpuShot(this.direction, this.frequency);
}
