import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// How an NPC plays its turns
enum NpcBehaviour {
  /// Balanced (default): it walks around mines when the detour is short and,
  /// everything else being equal, it avoids ending the turn under fire
  hunter,

  /// It charges: mines and the enemy line of fire don't slow it down, it
  /// always takes the shortest way and hits as soon as it can
  brute,

  /// It defends a place instead of chasing: it never stops farther than
  /// tile.properties['guardRadius'] tiles from where it started the battle
  guard,

  /// It shoots from afar: among the positions that cost the same moves it
  /// picks the farthest and the safest one
  sniper,
}

/// Manage movements and shots (NPC)
/// Add this as a child of a [Walker]
class NpcController extends Component {
  @override
  void onMount() {
    npc = parent as Walker;
    _timeToNextMove = _updatePeriod;
    _declaredBehaviour = NpcBehaviour.values.firstWhere(
      (b) => b.name == npc.tile.properties['behaviour'],
      orElse: () => NpcBehaviour.hunter,
    );
    _guardRadius = int.parse(npc.tile.properties['guardRadius'] ?? '3');
    if (npc.tile.properties['movementPattern'] != null) {
      npc.tile.properties['movementPattern'].split(',').forEach((m) {
        _movementPattern.add(GetDirection.fromInt(int.parse(m)));
      });
    }
    super.onMount();
  }

  late Walker npc;
  XeonjiaGame get game => npc.game;

  /// Behaviour declared by the map
  late final NpcBehaviour _declaredBehaviour;

  /// Radius of the area defended by a [NpcBehaviour.guard]
  late final int _guardRadius;

  /// Tile a [NpcBehaviour.guard] defends: where it stood on its first turn
  Point<int>? _home;

  /// Side of [_claimedTarget] this NPC is heading to
  /// It is the direction it would look at while attacking, and it is read by
  /// its allies so that they can pick a different one
  Direction? _claimedSide;
  Walker? _claimedTarget;

  /// Sides of [target] already taken by the allies still in play
  Set<Direction> _sidesTakenAround(Walker target) {
    final taken = <Direction>{};
    for (final other in game.players) {
      if (other == npc ||
          !game.isEnemy(other) ||
          other.deleted ||
          other.isBeingDeleted) {
        continue;
      }
      final ally = other.children.whereType<NpcController>().firstOrNull;
      if (ally != null && ally._claimedTarget == target) {
        final side = ally._claimedSide;
        if (side != null) taken.add(side);
      }
    }
    return taken;
  }

  /// Behaviour really played, see [NpcBehaviour.sniper]
  NpcBehaviour get _behaviour =>
      _declaredBehaviour == NpcBehaviour.sniper &&
          _usableWeapon(Weapons.snowball.id) == null
      ? NpcBehaviour.hunter
      : _declaredBehaviour;

  /// Frequency of movements
  final double _updatePeriod = 0.75;
  late double _timeToNextMove;

  /// Maximum number of tiles evaluated while looking for a path
  static const int _maxSearchedTiles = 2048;

  /// Maximum number of tiles traveled by a thrown weapon
  static const int _shotRange = 12;

  int get _maxSlide => max(game.map.width, game.map.height);

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
      npc.game.add(
        TimerComponent(
          period: 0.5,
          onTick: () {
            _movementInQueue = false;
            npc.updateDirection(
              _hasMovements ? _nextDirection : GetDirection.random,
              animated: false,
            );
            if (++_movementPatternIndex >= _movementPattern.length) {
              _movementPatternIndex = 0;
            }
          },
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // Decisions
  // --------------------------------------------------------------------------

  /// Components this NPC is fighting against
  List<Walker> get _targets => game.players
      .where(
        (p) =>
            p.teamId != npc.teamId &&
            !game.isEnemy(p) &&
            !p.deleted &&
            !p.isBeingDeleted &&
            p.hp > 0,
      )
      .toList();

  /// Choose and play the best action available for the current move
  void _fight() {
    final targets = _targets;
    if (targets.isEmpty) {
      _skipTurn();
      return;
    }
    // A guard defends the place where it was when the battle started
    _home ??= npc.gridTile;

    // Explored once and shared by the whole decision, see [_Paths]
    final straight = _reachableTiles(avoidModifiers: false);
    final paths = _Paths(
      direct: straight,
      safe: _behaviour == NpcBehaviour.brute
          ? straight
          : _reachableTiles(avoidModifiers: true),
    );
    final safe = _bestPlan(targets, paths.safe);
    final direct = _bestPlan(targets, paths.direct);
    final plan =
        (safe == null || (direct != null && safe.moves - direct.moves >= 3))
        ? direct
        : safe;

    // Tell the allies which side of which target this NPC is going for
    _claimedTarget = plan?.target;
    _claimedSide = plan?.direction;

    if (plan == null) {
      _approach(targets, paths);
    } else if (plan.moves > 0) {
      npc.updateDirection(plan.firstMove!, animated: false);
    } else {
      npc.updateOrientation(plan.direction);
      if (plan.weapon.id != Weapons.punch.id ||
          npc.componentInFront(plan.direction) == plan.target) {
        npc.shoot(plan.weapon.id);
      } else {
        _approach(targets, paths);
      }
    }
  }

  /// Best attack [npc] can prepare among the tiles it can [reach]
  /// It returns null if no target can be hit from any of them
  _AttackPlan? _bestPlan(List<Walker> targets, Map<Point<int>, _Step> reach) {
    _AttackPlan? best;
    for (final target in targets) {
      final taken = _behaviour == NpcBehaviour.brute
          ? const <Direction>{}
          : _sidesTakenAround(target);
      for (final position in _firingPositions(target)) {
        if (!_inGuardedArea(position.tile)) continue;
        final step = reach[position.tile];
        if (step == null) continue;
        final plan = _AttackPlan(
          target: target,
          weapon: position.weapon,
          direction: position.direction,
          range: position.range,
          moves: step.moves,
          firstMove: step.firstMove,
          behaviour: _behaviour,
          contested: taken.contains(position.direction),
          // A brute doesn't care about being shot back
          exposed:
              _behaviour != NpcBehaviour.brute &&
              _isExposed(position.tile, targets),
          remainingMoves: game.remainingMoves,
        );
        if (best == null || plan.isBetterThan(best)) best = plan;
      }
    }
    return best;
  }

  /// Get closer to the places the nearest target could be hit from
  void _approach(List<Walker> targets, _Paths paths) {
    final target = targets.reduce(
      (a, b) => npc.distance(a) <= npc.distance(b) ? a : b,
    );
    final goals = _firingPositions(target).map((p) => p.tile).toList();
    if (goals.isEmpty) goals.add(target.gridTile);
    final best =
        _closerStep(goals, paths.safe) ?? _closerStep(goals, paths.direct);
    best == null
        ? _skipTurn()
        : npc.updateDirection(best.firstMove!, animated: false);
  }

  /// Shortest path to the tile of [reach] nearest to one of the [goals]
  /// It returns null if [npc] can't get any closer than it already is
  _Step? _closerStep(List<Point<int>> goals, Map<Point<int>, _Step> reach) {
    var bestDistance = _distanceFrom(npc.gridTile, goals);
    _Step? best;
    reach.forEach((tile, step) {
      if (step.firstMove == null || !_inGuardedArea(tile)) return;
      final distance = _distanceFrom(tile, goals);
      if (distance < bestDistance ||
          (best != null &&
              distance == bestDistance &&
              step.moves < best!.moves)) {
        bestDistance = distance;
        best = step;
      }
    });
    return best;
  }

  /// Distance between [tile] and the nearest of the [goals]
  int _distanceFrom(Point<int> tile, List<Point<int>> goals) =>
      goals.map((g) => _manhattan(tile, g)).reduce(min);

  /// Give up the whole turn instead of burning one move at a time
  void _skipTurn() =>
      game.inBattle ? game.useMove(npc, skipTurn: true) : game.useMove(npc);

  /// Move towards a random direction
  /// It is used by friendly NPCs (they don't shoot) without a pattern
  void _wander() {
    final directions = Direction.values
        .where((d) => !_isBlocked(npc.gridTile, d))
        .toList();
    directions.isEmpty
        ? _skipTurn()
        : npc.updateDirection(
            directions[Random().nextInt(directions.length)],
            animated: false,
          );
  }

  // --------------------------------------------------------------------------
  // Weapons
  // --------------------------------------------------------------------------

  /// Return the weapon only if [npc] owns it and it still has shots
  Weapon? _usableWeapon(int id) => npc.hasWeaponId(id) && npc.hasPpForWeapon(id)
      ? npc.getWeaponById(id)
      : null;

  /// Every tile [target] could be hit from, with the weapon to use
  List<_FiringPosition> _firingPositions(Walker target) {
    final positions = <_FiringPosition>[];
    final punch = _usableWeapon(Weapons.punch.id);
    final snowball = _usableWeapon(Weapons.snowball.id);
    if (punch == null && snowball == null) return positions;
    for (final away in Direction.values) {
      var tile = target.gridTile;
      for (var distance = 1; distance <= _shotRange; distance++) {
        final weapon = distance == 1 ? _strongest(punch, snowball) : snowball;
        if (weapon == null) break;
        final next = Point(tile.x + away.dx, tile.y + away.dy);
        if (_shotIsBlocked(next, away.opposite, ignore: target)) break;
        tile = next;
        if (!_isFree(tile)) break;
        positions.add(_FiringPosition(tile, away.opposite, weapon, distance));
      }
    }
    return positions;
  }

  /// Weapon that inflicts more damage (the first one wins if they are equal)
  Weapon? _strongest(Weapon? first, Weapon? second) => first == null
      ? second
      : (second == null || first.atk >= second.atk ? first : second);

  /// True if [tile] can be hit by one of the [targets] without moving
  /// The NPC uses it to avoid ending its turn under fire
  bool _isExposed(Point<int> tile, List<Walker> targets) {
    for (final target in targets) {
      final origin = target.gridTile;
      if (origin == tile || (origin.x != tile.x && origin.y != tile.y)) {
        continue;
      }
      final distance = _manhattan(origin, tile);
      if (distance > 1 && !target.hasPpForWeapon(Weapons.snowball.id)) continue;
      final direction = GetDirection.fromXY(
        (tile.x - origin.x).toDouble(),
        (tile.y - origin.y).toDouble(),
      );
      var current = origin;
      var clear = true;
      for (var i = 0; i < distance; i++) {
        if (_shotIsBlocked(current, direction)) {
          clear = false;
          break;
        }
        current = Point(current.x + direction.dx, current.y + direction.dy);
      }
      if (clear) return true;
    }
    return false;
  }

  // --------------------------------------------------------------------------
  // Paths
  // --------------------------------------------------------------------------

  /// Tiles [npc] can reach, with the number of moves needed to get there
  /// and the direction of the first move of the path
  Map<Point<int>, _Step> _reachableTiles({required bool avoidModifiers}) {
    final start = npc.gridTile;
    final reached = <Point<int>, _Step>{start: const _Step(0, null)};
    final queue = Queue<Point<int>>()..add(start);
    while (queue.isNotEmpty && reached.length < _maxSearchedTiles) {
      final tile = queue.removeFirst();
      final step = reached[tile]!;
      for (final direction in Direction.values) {
        if (_isBlocked(tile, direction)) continue;
        final landing = _landingTile(tile, direction);
        if (landing == tile || reached.containsKey(landing)) continue;
        if (avoidModifiers && _hasModifier(landing)) continue;
        reached[landing] = _Step(step.moves + 1, step.firstMove ?? direction);
        queue.add(landing);
      }
    }
    return reached;
  }

  /// True if [npc] may take position on [tile]
  bool _inGuardedArea(Point<int> tile) {
    if (_behaviour != NpcBehaviour.guard || _home == null) return true;
    final distance = _manhattan(tile, _home!);
    return distance <= _guardRadius ||
        distance < _manhattan(npc.gridTile, _home!);
  }

  /// Tile where [npc] stops after a single move from [from] towards [direction]
  Point<int> _landingTile(Point<int> from, Direction direction) {
    var tile = from;
    var slide = direction;
    for (var i = 0; i < _maxSlide; i++) {
      if (_isBlocked(tile, slide)) return tile;
      tile = Point(tile.x + slide.dx, tile.y + slide.dy);
      final forced = _forcedDirection(tile);
      if (forced != null && forced != slide) {
        slide = forced;
      } else if (_stopsSlide(tile)) {
        return tile;
      }
    }
    return tile;
  }

  /// Direction imposed by a [DirectionChangerComponent] on [tile]
  Direction? _forcedDirection(Point<int> tile) {
    for (final c in game.componentsAt(tile)) {
      if (c is DirectionChangerComponent) return c.forcedDirection;
    }
    return null;
  }

  /// True if the floor of [tile] stops a component sliding over it
  bool _stopsSlide(Point<int> tile) => game
      .componentsAt(tile)
      .any(
        (c) =>
            c is StaticComponent && c.isFloor && !c.isSlippery && !c.isFlying(),
      );

  /// True if [tile] contains a mine or a pickable object
  /// [npc] walks around them: mines hurt and objects would be destroyed
  bool _hasModifier(Point<int> tile) => game
      .componentsAt(tile)
      .any((c) => c is ModifierComponent && !c.isBeingDeleted);

  /// True if [tile] is outside the map
  bool _outsideMap(Point<int> tile) =>
      tile.x < 0 ||
      tile.y < 0 ||
      tile.x >= game.map.width ||
      tile.y >= game.map.height;

  /// True if [npc] could stand on [tile]
  bool _isFree(Point<int> tile) {
    if (_outsideMap(tile)) return false;
    for (final c in game.componentsAt(tile)) {
      if (c == npc || c == npc.father || c.isBeingDeleted) continue;
      if (c is StaticComponent) {
        if (!c.isFloor && !c.isSlippery) return false;
        continue;
      }
      if (c.isFlying() ||
          c is ThinWallComponent ||
          c is HurdleComponent ||
          c is DirectionChangerComponent) {
        continue;
      }
      if (c.isSolid(otherComponent: npc)) return false;
    }
    return true;
  }

  /// True if [npc] can't walk from [from] to the next tile towards [direction]
  bool _isBlocked(Point<int> from, Direction direction) {
    final to = Point(from.x + direction.dx, from.y + direction.dy);
    if (!_isFree(to)) return true;
    for (final c in game.componentsAt(from)) {
      if (c is ThinWallComponent && c.isBlocking(direction)) return true;
      if (c is HurdleComponent && !c.allows(direction)) return true;
    }
    for (final c in game.componentsAt(to)) {
      if (c is ThinWallComponent && c.isBlocking(direction.opposite)) {
        return true;
      }
      if (c is HurdleComponent && !c.allows(direction)) return true;
    }
    return false;
  }

  /// True if a shot can't travel from [from] to the next tile
  /// towards [direction]
  bool _shotIsBlocked(
    Point<int> from,
    Direction direction, {
    BasicComponent? ignore,
  }) {
    final to = Point(from.x + direction.dx, from.y + direction.dy);
    if (_outsideMap(to)) return true;
    for (final c in game.componentsAt(from)) {
      if (c is ThinWallComponent && c.isBlocking(direction)) return true;
    }
    for (final c in game.componentsAt(to)) {
      if (c == npc || c == ignore || c.isBeingDeleted) continue;
      if (c is StaticComponent) {
        if (c.isSlippery) continue;
        if (!c.isFloor || c.isFlying()) return true;
        continue;
      }
      if (c.isFlying() ||
          c is ModifierComponent ||
          c is DirectionChangerComponent) {
        continue;
      }
      if (c is ThinWallComponent) {
        if (c.isBlocking(direction.opposite)) return true;
        continue;
      }
      if (c is HurdleComponent) {
        if (!c.allows(direction)) return true;
        continue;
      }
      if (c.isSolid(otherComponent: npc)) return true;
    }
    return false;
  }

  /// Distance (in moves, ignoring every obstacle) between two tiles
  int _manhattan(Point<int> a, Point<int> b) =>
      (a.x - b.x).abs() + (a.y - b.y).abs();

  @override
  void update(double dt) {
    if (game.isPaused || npc.quiet) return;
    if (_hasMovements) {
      _patternMove();
    } else if (game.isNotPaused &&
        npc.isMyTurn &&
        npc.isStationary &&
        !npc.isBeingDeleted &&
        !game.thereIsASnowball &&
        (_timeToNextMove -= dt) < 0) {
      _timeToNextMove = _updatePeriod;
      npc.friendly ? _wander() : _fight();
    }
  }
}

/// Tile [NpcController.npc] could shoot a target from
class _FiringPosition {
  const _FiringPosition(this.tile, this.direction, this.weapon, this.range);

  /// Tile the shooter has to stand on
  final Point<int> tile;

  /// Direction the shooter has to look at
  final Direction direction;

  /// Weapon to use
  final Weapon weapon;

  /// Distance (in tiles) between the shooter and the target
  final int range;
}

/// Tiles [NpcController.npc] can reach, explored once for the whole decision
class _Paths {
  const _Paths({required this.safe, required this.direct});

  /// Mines and pickable objects treated as walls
  final Map<Point<int>, _Step> safe;

  /// Straight over them
  final Map<Point<int>, _Step> direct;
}

/// Step of a path: how far a tile is and where the path starts
class _Step {
  const _Step(this.moves, this.firstMove);

  /// Number of moves needed to get there
  final int moves;

  /// Direction of the first move of the path (null on the starting tile)
  final Direction? firstMove;
}

/// Attack [NpcController.npc] can perform, possibly after having moved
class _AttackPlan {
  _AttackPlan({
    required this.target,
    required this.weapon,
    required this.direction,
    required this.range,
    required this.moves,
    required this.firstMove,
    required this.behaviour,
    required this.contested,
    required this.exposed,
    required int remainingMoves,
  }) : damage = max(0, weapon.atk - target.def),
       inRange = moves < remainingMoves;

  /// Moves an NPC accepts to walk to reach a free side of the target
  static const int _contestedPenalty = 3;

  /// Component that would be hit
  final Walker target;

  /// Weapon to use and direction to look at
  final Weapon weapon;
  final Direction direction;

  /// Distance (in tiles) the shot would travel
  final int range;

  /// Behaviour of the NPC, it decides how two plans are compared
  final NpcBehaviour behaviour;

  /// True if an ally is already heading to this side of the target
  final bool contested;

  /// Number of moves needed to get in position
  final int moves;

  /// Direction of the first move (null if [npc] is already in position)
  final Direction? firstMove;

  /// True if the firing position can be hit by the enemies
  final bool exposed;

  /// Damage really inflicted to [target] (its defence is subtracted)
  final double damage;

  /// True if the attack can be performed before the end of the current turn
  final bool inRange;

  /// True if [target] would be knocked out during the current turn
  bool get knockOut => inRange && damage >= target.hp;

  /// Moves needed, plus the detour an NPC accepts to leave a busy side to
  /// the ally that claimed it first
  int get cost => moves + (contested ? _contestedPenalty : 0);

  /// Compare two plans: knocking a target out comes first, then attacking
  /// during this turn, then the cheapest path ([cost], which counts the
  /// detour to leave a busy side to an ally), the strongest hit, the weakest
  /// target and finally the safest position
  bool isBetterThan(_AttackPlan other) {
    if (knockOut != other.knockOut) return knockOut;
    if (inRange != other.inRange) return inRange;
    if (inRange) {
      if (moves != other.moves) return moves < other.moves;
    } else if (cost != other.cost) {
      return cost < other.cost;
    }
    if (behaviour == NpcBehaviour.sniper) {
      if (exposed != other.exposed) return !exposed;
      if (range != other.range) return range > other.range;
    }
    if (damage != other.damage) return damage > other.damage;
    if (target.hp != other.target.hp) return target.hp < other.target.hp;
    return other.exposed && !exposed;
  }
}
