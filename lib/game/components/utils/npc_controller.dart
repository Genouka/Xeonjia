import 'package:flame/components.dart';
import 'package:xeonjia/game/components/character.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/weapons.dart';

// Manage movements and shots (NPC)
// Add this as a child of a Walker
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

  // Frequency of movements
  final double _updatePeriod = 0.5;
  late double _timeToNextMove;

  // Pattern defined in tile.properties['movementPattern'] (optional)
  final List<Direction> _movementPattern = [];
  int _movementPatternIndex = 0;
  Direction get _nextDirection => _movementPattern[_movementPatternIndex];
  bool get _hasMovements => _movementPattern.isNotEmpty;

  // Follow the pattern
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

  // Move free without pattern
  void _freeMove() {
    bool near = false;
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
    if (npc.hasPpForWeapon(Weapons.snowball.id) ||
        npc.componentInFront(newOrientation) == npc.gameRef.playerOne) {
      npc.updateOrientation(newOrientation);
      npc.shoot(npc.hasPpForWeapon(Weapons.snowball.id)
          ? Weapons.snowball.id
          : Weapons.punch.id);
    } else {
      if (!near) newOrientation = GetDirection.random;
      if (npc.componentInFront(newOrientation)?.isSolid(otherComponent: npc) ??
          false) {
        newOrientation = npc.orientation.opposite;
        if (npc
                .componentInFront(newOrientation)
                ?.isSolid(otherComponent: npc) ??
            false) {
          newOrientation = GetDirection.random;
          if (npc
                  .componentInFront(newOrientation)
                  ?.isSolid(otherComponent: npc) ??
              false) {
            npc.gameRef.useMove();
          }
        }
        npc.updateDirection(newOrientation, animated: false);
      } else {
        npc.updateDirection(newOrientation, animated: false);
      }
    }
    _timeToNextMove = _updatePeriod;
  }

  @override
  void update(double dt) {
    if (_hasMovements) {
      _patternMove();
    } else if (npc.gameRef.isNotPaused &&
        npc.isMyTurn &&
        (parent is! CharacterComponent ||
            !(parent as CharacterComponent).quiet) &&
        (_timeToNextMove -= dt) < 0) {
      _freeMove();
    }
  }
}
