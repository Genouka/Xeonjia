import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/static.dart';
import 'package:xeonjia/game/components/thin_wall.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/utils/weapons.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// Component able to move on the game field
mixin Walker on BasicComponent {
  @override
  Sprite getSpriteFromAtlas() => atlas.getSprite('$name-${orientation.index}');

  // Component orientation
  Direction _orientation = Direction.down;
  Direction get orientation => _orientation;

  // Component speed (componentSize per second)
  double get speed => defaultSpeed;

  // Number of moves done
  int movesCounter = 0;

  // If this is not moving, isStationary returns true
  bool get isStationary => direction == null;

  // True if this just moved (it's stationary but it's calculating the movement)
  bool wasStationary = true;

  // Map orientation : sprite
  final _sprites = <Direction, Sprite>{};

  @override
  Future<void>? onLoad() {
    if (atlasAsset == null) {
      const size = 16.0;
      for (final d in Direction.values) {
        _sprites[d] = Sprite(Flame.images.fromCache(image),
            srcPosition: Vector2(d.index * size, imageY),
            srcSize: Vector2.all(size));
      }
      updateOrientation();
    }
    return super.onLoad();
  }

  // If this component was previously still update its direction and orientation
  void updateDirection(Direction newDirection,
      {bool forced = false, bool animated = true}) {
    if (!isBeingDeleted && (isStationary || forced)) {
      wasStationary = true;
      direction = newDirection;
      updateOrientation();
      if (animated) {
        animation = atlas.getAnimation('$name-${direction!.index}-walking');
      }
      ++movesCounter;

      // Decrease life points cause poison
      if (poisonQuantity > 0) lifePointsDifference(-poisonQuantity);
    }
  }

  // Update component orientation
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

  // Recalculate component position
  void _move(double dt) {
    Rect? collidedRect;
    List<BasicComponent> collidedComponents = [];
    final overlappedComponents = <BasicComponent>[];

    // Distance traveled
    final delta = min(speed * dt, componentSize - 1);
    final candidatePositionTemp =
        toRect().translate(direction!.dx * delta, direction!.dy * delta);
    final candidatePosition = Rect.fromLTWH(
        candidatePositionTemp.left.gridAligned.toDouble(),
        candidatePositionTemp.top.gridAligned.toDouble(),
        candidatePositionTemp.width,
        candidatePositionTemp.height);

    // Check if this is going to collide or overlap another component
    for (final component in gameRef.children) {
      if (component is BasicComponent &&
          component != this &&
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
      for (final e in collidedComponents) {
        onCollision(e, wasStationary);
      }
      if (!wasStationary && (gameRef.isEnemy(this) || isPlayerOne)) {
        gameRef.useMove();
      }
    } else {
      // This component did not collide with another one
      x = candidatePosition.left;
      y = candidatePosition.top;
      for (final overlappedComponent in overlappedComponents) {
        overlappedComponent.overlappedBy(this);
      }
    }
    hasMoved();
    wasStationary = false;
  }

  // Function called if the component moved
  void hasMoved() {
    if ((isMyTurn && gameRef.enemies > 0) || this == gameRef.playerOne) {
      gameRef.updateCamera(x, y);
    }
  }

  // Function called when this component collide another component
  // ignore_for_file: avoid_positional_boolean_parameters
  void onCollision(BasicComponent collidedComponent,
      [bool wasStationary = false]) {
    stop();
    if (!isPlayerOne) {
      collidedComponent.lifePointsDifference(-atk,
          cause: this, poison: poisonAtk);
    } else if (settings.soundEffects &&
        (collidedComponent is! StaticComponent || !collidedComponent.isFloor)) {
      gameRef.playSound(Sfx.collision);
    }
    if (_wallInFront() == null) {
      collidedComponent.collidedBy(this, wasStationary);
    }
  }

  @mustCallSuper
  void stop() => direction = null;

  // Get components under this one
  List<BasicComponent> componentsUnder() {
    return gameRef.children
        .where((component) =>
            (component is StaticComponent || component is ThinWallComponent) &&
            (component as BasicComponent)
                .toRect()
                .contains(Offset(x + componentSize / 2, y + componentSize / 2)))
        .toList()
        .cast<BasicComponent>();
  }

  // Workaround (waiting for the priority/layers + collision fix)
  ThinWallComponent? _wallInFront() => componentsUnder().firstWhereOrNull(
          (c) => c is ThinWallComponent && c.isBlocking(orientation))
      as ThinWallComponent?;

  // Get component in front of this
  BasicComponent? componentInFront([Direction? orientation]) {
    var wall = _wallInFront();
    if (wall != null) return wall;
    Offset offset;
    switch (orientation ?? this.orientation) {
      case Direction.down:
        offset = Offset(x + componentSize / 2, y + componentSize * 3 / 2);
        break;
      case Direction.up:
        offset = Offset(x + componentSize / 2, y - componentSize / 2);
        break;
      case Direction.right:
        offset = Offset(x + componentSize * 3 / 2, y + componentSize / 2);
        break;
      case Direction.left:
        offset = Offset(x - componentSize / 2, y + componentSize / 2);
        break;
    }
    return gameRef.children
        .where((component) =>
            component is BasicComponent &&
            component.toRect().contains(offset) &&
            !component.isFlying() &&
            !component.isBeingDeleted)
        .sorted((a, b) => a.priority.compareTo(b.priority))
        .lastOrNull as BasicComponent?;
  }

  // List of weapon owned
  List<Weapon> weaponList = [];

  // Index of the weapon selected from weaponList
  int selectedWeaponIndex = 0;

  // Weapon
  Weapon get selectedWeapon => weaponList[selectedWeaponIndex];

  // True if this has the weapon
  bool hasWeaponId(int id) =>
      weaponList.where((weapon) => weapon.id == id).isNotEmpty;

  // True if this has the weapon and the weapon has at least one PP
  bool hasPpForWeapon(int id) =>
      (weaponList.firstWhereOrNull((w) => w.id == id)?.powerPoints ?? -1) > 0;

  // Return the weapon object by passing the id
  Weapon getWeaponById(int id) =>
      weaponList.firstWhere((weapon) => weapon.id == id);

  // Select next weapon in weapon list
  void nextWeapon() {
    if (++selectedWeaponIndex >= weaponList.length) selectedWeaponIndex = 0;
  }

  // Shoot with the weapon that has weapon.id == id or with the current weapon
  void shoot([int? id]) {
    if (isBeingDeleted || gameRef.isPaused || !isMyTurn || !isStationary) {
      return;
    }
    if (id != null) {
      var newWeaponIndex = weaponList.indexWhere((weapon) => weapon.id == id);
      if (weaponList[newWeaponIndex].powerPoints > 0) {
        selectedWeaponIndex = newWeaponIndex;
        selectedWeapon.shoot(shooter: this);
      }
    } else {
      selectedWeapon.shoot(shooter: this);
    }
    gameRef.useMove();
  }

  // Check if it is this component's turn during a battle
  bool get isMyTurn => gameRef.enemies > 0
      ? (gameRef.players.isNotEmpty ? this == gameRef.activePlayer : false)
      : true;

  @override
  int get priority => 125;

  final Paint _paint = Paint()
    ..color = const Color(0xFFB63C3F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void render(Canvas canvas) {
    if (isMyTurn && gameRef.enemies > 0) {
      canvas.drawOval(
          Rect.fromLTWH(0, size.y / 1.5, size.x, size.y / 2), _paint);
    }
    super.render(canvas);
  }
}
