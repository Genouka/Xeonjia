import 'dart:math';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/static/basic_static.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Component able to move on the game field
abstract class DynamicComponent extends BasicComponent {
  DynamicComponent(Point startingPosition, String imageName,
      {double imageY = 0})
      : super(startingPosition, imageName, imageY: imageY);

  // Constructor used when component is imported from a tmx file
  DynamicComponent.fromTile(tile) : super.fromTile(tile);

  // Component orientation
  Direction orientation = Direction.down;

  // Distance made at each frame update
  double distancePerUpdate = defaultDistancePerUpdate;

  // Component collided
  BasicComponent collidedComponent;

  // Number of moves done
  int movesCounter = 0;

  // If this is not moving, isStationary returns true
  bool get isStationary => direction == null;

  // Map orientation : sprite
  final _sprites = <Direction, Sprite>{};
  final _walkingSprites = <Direction, Sprite>{};
  final punchSprites = <Direction, Sprite>{};

  @override
  void onCreate() {
    final size = 16.0;
    Direction.values.forEach((d) {
      _sprites[d] = Sprite(image,
          x: d.index * size, y: imageY, width: size, height: size);
      _walkingSprites[d] =
          Sprite(image, x: d.index * size, y: size, width: size, height: size);
      punchSprites[d] = Sprite(image,
          x: d.index * size, y: size * 2, width: size, height: size);
    });
    super.onCreate();
  }

  // If this component was previously still update its direction and orientation
  void updateDirection(Direction newDirection, {bool forced = false}) {
    if (!isBeingDeleted && (isStationary || forced)) {
      direction = newDirection;
      updateOrientation();
      animate([_walkingSprites[orientation]]);
      ++movesCounter;

      // Decrease life points cause poison
      if (poisonQuantity > 0) lifePointsDifference(-poisonQuantity);
    }
  }

  // Update component orientation
  void updateOrientation([Direction newDirection]) {
    orientation = (newDirection ?? direction ?? orientation);
  }

  @override
  void render(Canvas canvas) {
    sprite = _sprites[orientation];
    super.render(canvas);
  }

  @override
  void update(double t) {
    _move();
    super.update(t);
  }

  // Recalculate component position
  // I should to fix this...
  void _move() {
    collidedComponent = null;
    var _overlappedComponents = <BasicComponent>[];
    if (direction != null) {
      var _newX = x + direction.dx * distancePerUpdate;
      var _newY = y + direction.dy * distancePerUpdate;
      var _newPosition = Rect.fromLTWH(_newX, _newY, width - 1, height - 1);
      game.components.forEach((component) {
        // If this is going to overlap an unrelated component
        if (component is BasicComponent &&
            component != this &&
            component != father &&
            this != component.father &&
            component.toRect().overlaps(_newPosition)) {
          // If the overlapped component is solid -> collide component
          if (component.isSolid(otherComponent: this)) {
            collidedComponent = component;
            return;
          } else {
            // Else -> overlap component
            _overlappedComponents.add(component);
          }
        }
      });
      // If this has overlapped another component -> stop this move
      if (collidedComponent != null) {
        onCollision();
      } else {
        // Else move this component
        x = _newX;
        y = _newY;
        hasMoved();
        _overlappedComponents.forEach(
            (_overlappedComponent) => _overlappedComponent.overlappedBy(this));
      }
    }
  }

  // Function called if the component moved
  void hasMoved() {}

  // Function called when this component collide another component
  void onCollision() {
    lifePointsDifference(-collidedComponent.atk, cause: collidedComponent);
    if (collidedComponent is! BasicStaticComponent) {
      collidedComponent.lifePointsDifference(-atk,
          cause: this, poison: poisonAtk);
    }
    stop();
  }

  void stop() {
    direction = null;
  }

  // Get component in front of this
  BasicComponent componentInFront() {
    Offset offset;
    switch (orientation) {
      case Direction.down:
        offset = Offset(x, y + componentSize * 3 / 2);
        break;
      case Direction.up:
        offset = Offset(x, y - componentSize / 2);
        break;
      case Direction.right:
        offset = Offset(x + componentSize * 3 / 2, y);
        break;
      case Direction.left:
        offset = Offset(x - componentSize / 2, y);
        break;
    }
    var components = game.components.where((component) =>
        component is BasicComponent &&
        component.toRect().contains(offset) &&
        !component.isFlying());
    return components.isNotEmpty ? components.last : null;
  }

  @override
  int priority() => 10;

  // Generate random number between -0.5 and +0.5
  // It is used to generate random direction for CPU-moved characters
  double randomDouble() => Random().nextDouble() - 0.5;
}
