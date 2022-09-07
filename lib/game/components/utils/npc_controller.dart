import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/static.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/weapons.dart';

/// Manage movements and shots (NPC)
/// Add this as a child of a [Walker]
class NpcController extends Component {
  @override
  void onMount() {
    npc = parent as Walker;
    _timeToNextMove = _updatePeriod;
    if (npc.tile.properties['movementPattern'] != null) {
      npc.tile.properties['movementPattern'].split(',').forEach((m) {
        _movementPattern.add(GetDirection.fromInt(int.parse(m)));
      });
    }
    super.onMount();
  }

  late Walker npc;

  /// Frequency of movements
  final double _updatePeriod = 0.5;
  late double _timeToNextMove;

  /// Pattern defined in tile.properties['movementPattern'] (optional)
  final List<Direction> _movementPattern = [];
  int _movementPatternIndex = 0;
  Direction get _nextDirection => _movementPattern[_movementPatternIndex];
  bool get _hasMovements => _movementPattern.isNotEmpty;

  /// Follow the pattern
  bool _movementInQueue = false;
  void _patternMove() {
    if (npc.isStationary && !_movementInQueue) {
      _movementInQueue = true;
      npc.gameRef.add(TimerComponent(
          period: 0.5,
          onTick: () {
            _movementInQueue = false;
            npc.updateDirection(
                _hasMovements ? _nextDirection : GetDirection.random,
                animated: false);
            if (++_movementPatternIndex >= _movementPattern.length) {
              _movementPatternIndex = 0;
            }
          }));
    }
  }

  /// Move freely without pattern
  // (the code/logic will be improved sooner or later)
  Direction? previousMove;
  void _freeMove() {
    if (npc.gameRef.remainingMoves == 3) previousMove = null;
    bool near = false;
    bool done = false;
    Direction newOrientation = npc.orientation;

    // Check if playerOne has the same x or y
    if (npc.gameRef.playerOne!.x == npc.x) {
      newOrientation =
          npc.gameRef.playerOne!.y > npc.y ? Direction.down : Direction.up;
      near = true;
    } else if (npc.gameRef.playerOne!.y == npc.y) {
      newOrientation =
          npc.gameRef.playerOne!.x > npc.x ? Direction.right : Direction.left;
      near = true;
    }

    // If npc can hit playerOne: shoot
    if (npc.componentInFront(newOrientation) == npc.gameRef.playerOne ||
        (npc.hasPpForWeapon(Weapons.snowball.id) && near)) {
      npc.updateOrientation(newOrientation);
      // If npc has remained stationary in this turn move away else shoot
      var weapon = npc.getWeaponById(npc.hasPpForWeapon(Weapons.snowball.id)
          ? Weapons.snowball.id
          : Weapons.punch.id);
      if (!(npc.gameRef.remainingMoves == 1 &&
          previousMove == null &&
          npc.gameRef.playerOne!.hp - weapon.atk > 0)) {
        done = true;
        npc.shoot(weapon.id);
      }
    }

    // If npc still have to do its move: try to move
    if (!done) {
      var remainingDirections = Direction.values.toSet().difference({
        if (previousMove != null) previousMove!.opposite,
      }).toList();
      if (!near) newOrientation = getCloserToPlayerOne(previousMove);
      if (!remainingDirections.contains(newOrientation) ||
          cantMoveInThisDirection(newOrientation)) {
        remainingDirections.remove(newOrientation);
        newOrientation = getCloserToPlayerOne(newOrientation);
        if (!remainingDirections.contains(newOrientation) ||
            cantMoveInThisDirection(newOrientation)) {
          remainingDirections.remove(newOrientation);
          newOrientation =
              remainingDirections[Random().nextInt(remainingDirections.length)];
          if (!remainingDirections.contains(newOrientation) ||
              cantMoveInThisDirection(newOrientation)) {
            remainingDirections.remove(newOrientation);
            if (remainingDirections.isEmpty ||
                cantMoveInThisDirection(remainingDirections.first)) {
              npc.gameRef.useMove(npc);
            } else {
              newOrientation = remainingDirections.first;
            }
          }
        }
        npc.updateDirection(newOrientation, animated: false);
        previousMove = newOrientation;
      } else {
        npc.updateDirection(newOrientation, animated: false);
        previousMove = newOrientation;
      }
    }
    _timeToNextMove = _updatePeriod;
  }

  bool cantMoveInThisDirection(Direction direction) {
    var component = npc.componentInFront(direction);
    return (component?.isSolid(otherComponent: npc) ?? false) &&
        !(component is StaticComponent && component.isFloor);
  }

  Direction getCloserToPlayerOne([Direction? directionAvoided]) {
    if ([Direction.right, Direction.left].contains(directionAvoided) ||
        Random().nextBool()) {
      return npc.gameRef.playerOne!.y > npc.y ? Direction.down : Direction.up;
    } else {
      return npc.gameRef.playerOne!.x > npc.x
          ? Direction.right
          : Direction.left;
    }
  }

  @override
  void update(double dt) {
    if (npc.gameRef.isPaused || npc.quiet) return;
    if (_hasMovements) {
      _patternMove();
    } else if (npc.gameRef.isNotPaused &&
        npc.isMyTurn &&
        (_timeToNextMove -= dt) < 0) {
      _freeMove();
    }
  }
}
