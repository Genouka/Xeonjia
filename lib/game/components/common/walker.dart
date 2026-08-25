import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Component able to move on the game field
mixin Walker on BasicComponent {
  @override
  Sprite getSpriteFromAtlas() => atlas.getSprite('$name-${orientation.index}');

  /// Component orientation
  Direction _orientation = Direction.down;
  Direction get orientation => _orientation;

  /// Default component speed ([componentSize] per second)
  static double get defaultSpeed => componentSize * 8;

  /// Component speed ([componentSize] per second)
  double get speed => defaultSpeed;
  double _slowedMove = 0;

  /// Number of moves done
  int movesCounter = 0;

  /// If this is not moving, isStationary returns true
  bool get isStationary => direction == null;

  /// True if this just moved: it's stationary but it's calculating the movement
  bool wasStationary = true;

  /// Map orientation : sprite
  final _sprites = <Direction, Sprite>{};

  /// NPC features: If friendly it doesn't shoot. If quiet it doesn't move.
  bool friendly = true;
  bool quiet = true;

  @override
  Future<void>? onLoad() {
    if (atlasAsset == null) {
      const size = 16.0;
      for (final d in Direction.values) {
        _sprites[d] = Sprite(
          Flame.images.fromCache(image),
          srcPosition: Vector2(d.index * size, imageY),
          srcSize: Vector2.all(size),
        );
      }
      updateOrientation();
    }
    return super.onLoad();
  }

  /// If this component was previously still update its
  /// [direction] and [_orientation]
  void updateDirection(
    Direction newDirection, {
    bool forced = false,
    bool animated = true,
    bool slow = false,
  }) {
    if (!isBeingDeleted && (isStationary || forced) && !game.thereIsASnowball) {
      wasStationary = true;
      _slowedMove = slow ? 0.2 : 0;
      if (animated &&
          ((animationTicker?.done() ?? true) || orientation != newDirection)) {
        animation = atlas.getAnimation('$name-${newDirection.index}-walking');
        animationTicker = SpriteAnimationTicker(animation!);
      }
      direction = newDirection;
      updateOrientation();
      ++movesCounter;

      // Decrease health points cause poison
      if (poisonQuantity > 0) hpDifference(-poisonQuantity);
    }
  }

  /// Update component [_orientation]
  void updateOrientation([Direction? newDirection]) {
    _orientation = newDirection ?? direction ?? orientation;
    sprite = atlasAsset == null
        ? _sprites[orientation]
        : atlas.getSprite('${name!}-${orientation.index}');
  }

  @override
  void update(double dt) {
    if (!isStationary) _move(dt);
    super.update(dt);
  }

  /// Recalculate component position
  void _move(double dt) {
    _slowedMove -= dt;
    Rect? collidedRect;
    List<BasicComponent> collidedComponents = [];
    final overlappedComponents = <BasicComponent>[];

    // Distance traveled
    final delta = min(
      (_slowedMove > 0 ? speed * 0.6 : speed) * dt,
      componentSize - 1,
    );
    final candidatePosition = Rect.fromLTWH(
      (x + direction!.dx * delta).gridAligned.toDouble(),
      (y + direction!.dy * delta).gridAligned.toDouble(),
      width,
      height,
    );

    // Check if this is going to collide or overlap another component
    final current = gridTile;
    final next = Point(current.x + direction!.dx, current.y + direction!.dy);
    final nearby = [...game.componentsAt(current), ...game.componentsAt(next)];
    for (final component in nearby) {
      if (component != this &&
          component != father &&
          this != component.father) {
        var componentCollisionRect = component.collisionRect(this);
        if (componentCollisionRect?.approximateOverlaps(candidatePosition) ??
            false) {
          if (component.isSolid(otherComponent: this)) {
            collidedComponents.add(component);
            collidedRect = componentCollisionRect;
          } else {
            overlappedComponents.add(component);
          }
        }
      }
    }

    if (collidedRect != null) {
      // This component collided another one
      if (direction!.dx < 0) {
        x = collidedRect.right;
      } else if (direction!.dx > 0) {
        x = collidedRect.left - width;
      } else if (direction!.dy < 0) {
        y = collidedRect.bottom;
      } else if (direction!.dy > 0) {
        y = collidedRect.top - height;
      }
      for (final e in collidedComponents.sorted(
        (a, b) => a is DirectionChangerComponent
            ? 1
            : a.priority.compareTo(b.priority),
      )) {
        onCollision(e, wasStationary);
      }
      hasMoved();
    } else {
      // This component did not collide with another one
      x = candidatePosition.left;
      y = candidatePosition.top;
      for (final overlappedComponent in overlappedComponents) {
        overlappedComponent.overlappedBy(this);
      }
    }
    // Update grid position after moving
    game.gridRegister(this);
    isMoving();
    wasStationary = false;
  }

  /// Function called if the component is moving
  void isMoving() {
    if ((isMyTurn && game.inBattle) || this == game.playerOne) {
      game.updateCamera(x, y);
    }
  }

  /// Function called if the component moved
  void hasMoved() {
    if (!wasStationary && (game.isEnemy(this) || isUser)) {
      game.useMove(this);
    }
  }

  /// Function called when this component collide another component
  // ignore_for_file: avoid_positional_boolean_parameters
  double _lastCollisionSoundTime = -1;
  void onCollision(
    BasicComponent collidedComponent, [
    bool wasStationary = false,
  ]) {
    stop();
    if (!isUser) {
      collidedComponent.hpDifference(-atk, cause: this, poison: poisonAtk);
    } else if (settings.soundEffects &&
        (collidedComponent is! StaticComponent || !collidedComponent.isFloor)) {
      if (game.elapsed - _lastCollisionSoundTime > 1) {
        game.playSound(Sfx.collision, volume: 0.4);
        _lastCollisionSoundTime = game.elapsed;
      }
    }
    if (_wallInFront() == null) {
      collidedComponent.collidedBy(this, wasStationary);
    }
  }

  @mustCallSuper
  void stop() {
    direction = null;
    _slowedMove = 0;
  }

  /// Get components under this one
  List<BasicComponent> componentsUnder() => game
      .componentsAt(gridTile)
      .where((c) => c is StaticComponent || c is ThinWallComponent)
      .toList();

  /// Check if a ThinWall is in front of this
  ThinWallComponent? _wallInFront() {
    for (final c in game.componentsAt(gridTile)) {
      if (c is ThinWallComponent && c.isBlocking(orientation)) return c;
    }
    return null;
  }

  /// Get component in front of this
  BasicComponent? componentInFront([Direction? orientation]) {
    final wall = _wallInFront();
    if (wall != null) return wall;
    final dir = orientation ?? this.orientation;
    final target = Point(gridTile.x + dir.dx, gridTile.y + dir.dy);
    BasicComponent? best;
    for (final c in game.componentsAt(target)) {
      if (c.isFlying() || c.isBeingDeleted) continue;
      if (best == null || c.priority >= best.priority) best = c;
    }
    return best;
  }

  /// List of weapon owned
  List<Weapon> weaponList = [];

  /// True if this has the weapon
  bool hasWeaponId(int id) => weaponList.any((weapon) => weapon.id == id);

  /// True if this has the weapon and the weapon has at least one PP
  bool hasPpForWeapon(int id) =>
      (weaponList.firstWhereOrNull((w) => w.id == id)?.powerPoints ?? -1) > 0;

  /// Return the weapon object by passing the id
  Weapon getWeaponById(int id) =>
      weaponList.firstWhere((weapon) => weapon.id == id);

  /// Shoot with the weapon that has weapon.id == id or with the current weapon
  void shoot(int id) {
    if (!game.inBattle ||
        isBeingDeleted ||
        game.isPaused ||
        !isMyTurn ||
        !isStationary) {
      return;
    }
    double previousPP = 0;
    var weapon = weaponList.firstWhere((weapon) => weapon.id == id);
    if (weapon.powerPoints > 0) {
      previousPP = weapon.powerPoints;
      weapon.shoot(shooter: this);
    } else {
      game.setMessage(
        Message(
          game,
          "I've run out of shots for this weapon.".i18n,
          author: '/' + (game.user?.name ?? 'hero'),
        ),
      );
    }
    if ((weapon.maxPp == double.infinity || weapon.powerPoints != previousPP) &&
        weapon.id != Weapons.snowball.id) {
      game.useMove(this);
    }
  }

  /// Check if it is this component's turn during a battle
  bool get isMyTurn => game.enemies > 0
      ? (game.players.isNotEmpty ? this == game.activePlayer : false)
      : true;

  @override
  int get priority => 125;

  final Paint _paint = Paint()
    ..color = const Color(0xFFB63C3F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void render(Canvas canvas) {
    if (isMyTurn && game.inBattle && !game.miniMapEnabled && !isBeingDeleted) {
      canvas.drawOval(
        Rect.fromLTWH(0, size.y / 1.5, size.x, size.y / 2.35),
        _paint,
      );
    }
    super.render(canvas);
  }
}
