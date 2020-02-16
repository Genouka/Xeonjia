import 'dart:math';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Component able to move on the game field
abstract class DynamicComponent extends BasicComponent {
  DynamicComponent(double startX, double startY, String imageName)
      : super(startX, startY, imageName);

  // Constructor used when component is imported from a tmx file
  DynamicComponent.fromTile(tile) : super.fromTile(tile);

  // Component orientation
  // 1: down, 2: up, 3: right, 4: left
  int orientation = 1;

  // Direction values
  // They equal to zero if the component is not moving
  double directionX = 0;
  double directionY = 0;

  // Distance made at each frame update
  double distancePerFrame = defaultDistancePerFrame;

  // Component collided
  BasicComponent collidedComponent;

  // Number of moves done
  int movesCounter = 0;

  // If this component was previously still update its direction and orientation
  void updateDirection(double newInputDirectionX, double newInputDirectionY,
      {bool forced = false}) {
    if ((directionX == 0 && directionY == 0) || forced) {
      directionX = newInputDirectionX;
      directionY = newInputDirectionY;

      updateOrientation(directionX, directionY);
      ++movesCounter;

      // Decrease life points cause poison
      lifePointsDifference(-poisonQuantity);
    }
  }

  // Update component orientation
  void updateOrientation(double x, double y) {
    if (x != 0 || y != 0) {
      if (y > 0) {
        orientation = 1;
      } else if (y < 0) {
        orientation = 2;
      } else if (x > 0) {
        orientation = 3;
      } else if (x < 0) orientation = 4;

      updateSprite();
    }
  }

  // Update sprite image based on its orientation
  void updateSprite() {
    sprite = Sprite(
        (image).split('-').first + '-' + orientation.toString() + '.png');
  }

  @override
  @mustCallSuper
  void update(double t) {
    _move();
  }

  // Recalculate component position
  // I should to fix this...
  void _move() {
    collidedComponent = null;
    BasicComponent _overlappedComponent;
    if (directionX != 0 || directionY != 0) {
      double _newX = x + directionX.sign * distancePerFrame;
      double _newY = y + directionY.sign * distancePerFrame;
      Rect _newPosition = Rect.fromLTWH(_newX, _newY, width - 1, height - 1);
      game.components.cast<BasicComponent>().forEach((component) {
        // If this is going to overlap an unrelated component
        if (component != this &&
            component != father &&
            this != component.father &&
            component.toRect().overlaps(_newPosition)) {
          // If the overlapped component is solid -> collide component
          if (component.isSolid(otherComponent: this)) {
            collidedComponent = component;
            return;
          } else {
            // Else -> overlap component
            _overlappedComponent = component;
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
        _overlappedComponent?.overlappedBy(this);
      }
    }
  }

  // Function called if the component moved
  void hasMoved() {}

  // Function called when this component collide another component
  void onCollision() {
    lifePointsDifference(-collidedComponent.atk, cause: collidedComponent);
    collidedComponent.lifePointsDifference(-atk,
        cause: this, poison: poisonAtk);
    stop();
  }

  void stop() {
    directionX = 0;
    directionY = 0;
  }

  @override
  int priority() => 10;

  // Generate random number between -0.5 and +0.5
  // It is used to generate random direction for CPU-moved characters
  double randomDouble() => Random().nextDouble() - 0.5;
}

// Convert int direction into X and Y
List<double> directionToXY(int direction) {
  double _directionX;
  double _directionY;
  switch (direction) {
    case 1:
      _directionX = 0;
      _directionY = 1;
      break;
    case 2:
      _directionX = 0;
      _directionY = -1;
      break;
    case 3:
      _directionX = 1;
      _directionY = 0;
      break;
    case 4:
      _directionX = -1;
      _directionY = 0;
      break;
    default:
      _directionX = 0;
      _directionY = 0;
      break;
  }
  return [_directionX, _directionY];
}
