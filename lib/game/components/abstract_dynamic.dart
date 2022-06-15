import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/static/static.dart';
import 'package:xeonjia/game/components/static/thin_wall.dart';
import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/util/text_animation.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Component able to move on the game field
abstract class DynamicComponent extends BasicComponent with TextAnimation {
  DynamicComponent(
      int id, Point startingPosition, Map<String, dynamic> properties)
      : super(id, startingPosition, properties);

  // Constructor used when component is imported from a tmx file
  DynamicComponent.fromTile(tile) : super.fromTile(tile);

  // Component orientation
  Direction orientation = Direction.down;

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
  final _walkingSprites = <Direction, Sprite>{};
  final punchSprites = <Direction, Sprite>{};

  @override
  void onCreate() {
    const size = 16.0;
    for (final d in Direction.values) {
      _sprites[d] = Sprite(game.images.fromCache(image),
          srcPosition: Vector2(d.index * size, size),
          srcSize: Vector2.all(size));
      _walkingSprites[d] = Sprite(game.images.fromCache(image),
          srcPosition: Vector2(d.index * size, size),
          srcSize: Vector2.all(size));
      punchSprites[d] = Sprite(game.images.fromCache(image),
          srcPosition: Vector2(d.index * size, size * 2),
          srcSize: Vector2.all(size));
    }
    super.onCreate();
  }

  // If this component was previously still update its direction and orientation
  void updateDirection(Direction newDirection,
      {bool forced = false, bool animated = true}) {
    if (!isBeingDeleted && (isStationary || forced)) {
      wasStationary = true;
      direction = newDirection;
      updateOrientation();
      if (animated) animate([_walkingSprites[orientation]]);
      ++movesCounter;

      // Decrease life points cause poison
      if (poisonQuantity > 0) lifePointsDifference(-poisonQuantity);
    }
  }

  // Update component orientation
  void updateOrientation([Direction newDirection]) {
    orientation = newDirection ?? direction ?? orientation;
  }

  @override
  void render(Canvas canvas) {
    sprite = _sprites[orientation];
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (direction != null) _move(dt);
    super.update(dt);
  }

  // Recalculate component position
  void _move(double dt) {
    Rect collidedRect;
    List<BasicComponent> collidedComponents = [];
    final overlappedComponents = <BasicComponent>[];

    // Distance traveled
    final delta = min(speed * dt, componentSize - 1);
    final candidatePositionTemp =
        toRect().translate(direction.dx * delta, direction.dy * delta);
    final candidatePosition = Rect.fromLTWH(
        candidatePositionTemp.left.gridAligned,
        candidatePositionTemp.top.gridAligned,
        candidatePositionTemp.width,
        candidatePositionTemp.height);

    // Check if this is going to collide or overlap another component
    for (final component in game.children) {
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
      if (direction.dx < 0) {
        x = collidedRect.right;
      } else if (direction.dx > 0) {
        x = collidedRect.left - width;
      } else if (direction.dy < 0) {
        y = collidedRect.bottom;
      } else if (direction.dy > 0) {
        y = collidedRect.top - height;
      }
      for (final e in collidedComponents) {
        onCollision(e);
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
  void hasMoved() {}

  // Function called when this component collide another component
  void onCollision(BasicComponent collidedComponent) {
    stop();
    if (!isPlayerOne) {
      collidedComponent.lifePointsDifference(-atk,
          cause: this, poison: poisonAtk);
    } else if (settings.soundEffects &&
        (collidedComponent is! StaticComponent ||
            !(collidedComponent as StaticComponent).isFloor)) {
      game.playSound(Sfx.collision);
    }
    if (_wallInFront() == null) {
      collidedComponent.collidedBy(this);
    }
  }

  @mustCallSuper
  void stop() {
    direction = null;
  }

  // Get components under this one
  List<BasicComponent> componentsUnder() {
    return game.children
        .where((component) =>
            (component is StaticComponent || component is ThinWallComponent) &&
            (component as BasicComponent)
                .toRect()
                .contains(Offset(x + componentSize / 2, y + componentSize / 2)))
        .toList()
        .cast<BasicComponent>();
  }

  // Workaround waiting for the priority/layers + collision fix
  ThinWallComponent _wallInFront() {
    return componentsUnder().firstWhereOrNull(
        (c) => c is ThinWallComponent && c.isBlocking(orientation));
  }

  // Get component in front of this
  BasicComponent componentInFront() {
    var wall = _wallInFront();
    if (wall != null) return wall;
    Offset offset;
    switch (orientation) {
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
    return game.children
        .where((component) =>
            component is BasicComponent &&
            component.toRect().contains(offset) &&
            !component.isFlying() &&
            !component.isBeingDeleted)
        .sorted((a, b) => a.priority.compareTo(b.priority))
        .lastOrNull;
  }

  @override
  int get priority => 125;

  // Generate random number between -0.5 and +0.5
  // It is used to generate random direction for CPU-moved characters
  double randomDouble() => Random().nextDouble() - 0.5;
}
