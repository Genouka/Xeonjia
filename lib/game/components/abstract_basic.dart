import 'dart:math';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/basic_static.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/tile.dart';

// Basic game component
// Every game component extends this one
abstract class BasicComponent extends SpriteComponent {
  // Component starting position
  Point startingPosition;

  // Component image file
  // Not used if it is instantiated by BasicComponent.fromTile()
  String image;

  // Initial life points
  double initialLifePoints = double.infinity;

  // Component level
  int level = 0;

  // Experience points gained during match
  int experiencePoints = 0;

  // Current life points
  // Value accessed by using lifePoints getter
  // Value edited by using lifePointsDifference() method
  double _lifePoints;

  // Poison released to enemies during collision
  double poisonAtk = 0;

  // Poison in this component
  // It reduce life points when move
  double poisonQuantity = 0;

  // Enemies killed by this component
  int killedEnemies = 0;

  // Number of times this died
  int deaths = 0;

  // Player points (100 points for each CharacterComponents killed)
  int points = 0;

  // Amount of damage done on collision
  double atk = 0;

  // Amount of protected damage
  double def = 0;

  // Direction values
  // They equal to zero if the component is not moving
  Direction direction;

  // True if this component has to be removed from game
  bool remove = false;

  // Component that generated this one
  // A component can't collide with its father
  // Mainly used for weapon shot
  BasicComponent father;

  // This component's team
  // It is used to avoid friendly fire among components of the same species
  // It is also used in multiplayer matches to manage team membership
  int teamId = -1;
  Team get team => game.teams.firstWhere((team) => team.id == teamId);

  BasicComponent.fromTile(Tile tile)
      : startingPosition = tile.position,
        initialLifePoints =
            double.parse(tile.properties['lifePoints'] ?? 'Infinity'),
        atk = double.parse(tile.properties['atk'] ?? '0'),
        def = double.parse(tile.properties['def'] ?? '0'),
        poisonAtk = double.parse(tile.properties['poisonAtk'] ?? '0'),
        super.fromSprite(tile.size, tile.size, tile.sprite) {
    onCreate();
  }

  BasicComponent(this.startingPosition, this.image, {int imageRow = 0})
      : initialLifePoints = double.infinity,
        super.fromSprite(
          componentSize,
          componentSize,
          Sprite(image, width: 16, height: 16, y: 16.0 * imageRow),
        ) {
    onCreate();
  }

  BasicComponent.withoutImage(this.startingPosition)
      : initialLifePoints = double.infinity {
    onCreate();
  }

  @mustCallSuper
  void onCreate() {
    _lifePoints = initialLifePoints;
    x = startingPosition.x;
    y = startingPosition.y;
    game.addLater(this);
  }

  double get lifePoints => _lifePoints;

  // Function used to change life points
  void lifePointsDifference(double difference,
      {BasicComponent cause, double poison = 0}) {
    if (game.friendlyFire || teamId != (cause?.teamId ?? -99)) {
      _lifePoints += difference < 0 ? difference + def : difference;
      poisonQuantity += poison;
      if (this == playerOne && difference != 0) game.refreshLifePointsBar();
      if (_lifePoints <= 0) {
        delete();
        if (teamId == (cause?.teamId ?? -99)) {
          // Teammate killed
          game.teams.forEach((team) {
            if (team.id != teamId) team.basisPoints += 10;
          });
        } else if (this is! BasicStaticComponent) {
          // Enemy killed
          cause?.killedEnemies++;
          cause?.experiencePoints += level;
          if (this is CharacterComponent) cause?.points += 100;
        }
      }
    }
  }

  // True if this component could be collided
  // It depends on component that would collide this one
  bool isSolid({@required DynamicComponent otherComponent}) => true;

  // True if this component is flying
  bool isFlying() => false;

  // Define what happens if this component has been overlapped by another one
  // Used if isSolid() returned false
  void overlappedBy(DynamicComponent componentAbove) {}

  // Reset life points
  void restoreLifePoints() {
    _lifePoints = initialLifePoints;
    if (this == playerOne) game.refreshLifePointsBar();
  }

  // Delete component
  void delete() {
    ++deaths;
    remove = true;
  }

  @override
  bool destroy() => remove;

  // Delete every son of this component
  void removeChildren() {
    game.components.forEach((c) {
      if (c is BasicComponent && c.father == this) c.delete();
    });
  }
}
