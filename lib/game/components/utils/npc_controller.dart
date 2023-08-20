import 'dart:math';

import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia.dart';

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
  final double _updatePeriod = 0.75;
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
    CharacterComponent player = npc.gameRef.children
        .where((c) => c is CharacterComponent && c.teamId == 0)
        .reduce((curr, next) => npc.distance(curr as PositionComponent) <
                npc.distance(next as PositionComponent)
            ? curr
            : next) as CharacterComponent;
    // Check if player has the same x or y
    if (player.x == npc.x) {
      newOrientation = player.y > npc.y ? Direction.down : Direction.up;
      near = true;
    } else if (player.y == npc.y) {
      newOrientation = player.x > npc.x ? Direction.right : Direction.left;
      near = true;
    }

    // If npc can hit player: shoot
    if (npc.componentInFront(newOrientation) == player ||
        (npc.hasPpForWeapon(Weapons.snowball.id) && near)) {
      npc.updateOrientation(newOrientation);
      // If npc has remained stationary in this turn move away else shoot
      var weapon = npc.getWeaponById(npc.hasPpForWeapon(Weapons.snowball.id)
          ? Weapons.snowball.id
          : Weapons.punch.id);
      if (!(npc.gameRef.remainingMoves == 1 &&
          previousMove == null &&
          player.hp - weapon.atk > 0)) {
        done = true;
        npc.shoot(weapon.id);
      }
    }

    // If npc still have to do its move: try to move
    if (!done) {
      var remainingDirections = Direction.values.toSet().difference({
        if (previousMove != null) previousMove!.opposite,
      }).toList();
      if (!near) newOrientation = getCloserToPlayer(player, previousMove);
      if (!remainingDirections.contains(newOrientation) ||
          cantMoveInThisDirection(newOrientation)) {
        remainingDirections.remove(newOrientation);
        newOrientation = getCloserToPlayer(player, newOrientation);
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

  Direction getCloserToPlayer(CharacterComponent player,
      [Direction? directionAvoided]) {
    if ([Direction.right, Direction.left].contains(directionAvoided) ||
        Random().nextBool()) {
      return player.y > npc.y ? Direction.down : Direction.up;
    } else {
      return player.x > npc.x ? Direction.right : Direction.left;
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
