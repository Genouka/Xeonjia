import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/models/direction.dart';

// Manage movements and shots (NPC)
class NpcController {
  // Read and import patterns
  // movementPatternString: is a list of: direction
  // shotPatternString:     is a list of: direction | frequency
  NpcController(
      this.npc, String? movementPatternString, String? shotPatternString) {
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

  final CharacterComponent npc;

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
  bool _movementInQueue = false;
  void move() {
    if (!npc.quiet && npc.isStationary && !_movementInQueue) {
      _movementInQueue = true;
      npc.gameRef.add(TimerComponent(
          period: 0.5,
          onTick: () {
            _movementInQueue = false;
            npc.updateDirection(
                _hasMovements ? _nextDirection : GetDirection.random,
                animated: false);
          }));
    }
  }

  // Shoot
  bool _shotInQueue = false;
  void shoot() {
    if (!npc.friendly && !_shotInQueue) {
      _shotInQueue = true;
      npc.gameRef.add(TimerComponent(
          period: _hasShots ? _nextShot.frequency : 0.5,
          onTick: () {
            _shotInQueue = false;
            if (_hasShots) npc.updateOrientation(_nextShot.direction);
            if (npc.teamId != npc.gameRef.playerOne!.teamId) {
              if (npc.gameRef.playerOne!.x == npc.x) {
                npc.updateOrientation(npc.gameRef.playerOne!.y > npc.y
                    ? Direction.down
                    : Direction.up);
              } else if (npc.gameRef.playerOne!.y == npc.y) {
                npc.updateOrientation(npc.gameRef.playerOne!.x > npc.x
                    ? Direction.right
                    : Direction.left);
              }
            }
            if (Random().nextDouble() > 0.6) npc.nextWeapon();
            if (Random().nextDouble() > 0.8) npc.shoot();
          }));
    }
  }
}

class _CpuShot {
  _CpuShot(this.direction, this.frequency);
  Direction direction;
  double frequency;
}
