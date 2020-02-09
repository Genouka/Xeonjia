import 'package:flame/components/component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';
import 'package:xeonjia/src/screens/game/components/static/basic_static.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/game/utils/map_utils.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Basic game component
// Every game component extends this one
abstract class BasicComponent extends SpriteComponent {
  // Component start position
  double startX;
  double startY;

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

  // Amount of damage done on collision
  double atk = 0;

  // Amount of protected damage
  double def = 0;

  // True if this component has to be removed from game
  bool remove = false;

  // Component that generated this one
  // A component can't collide with its father
  // Mainly used for weapon shot
  BasicComponent father;

  BasicComponent.fromTile(Tile tile)
      : startX = tile.x,
        startY = tile.y,
        image = tile.image,
        initialLifePoints =
            double.parse(tile.properties['lifePoints'] ?? 'Infinity'),
        atk = double.parse(tile.properties['atk'] ?? '0'),
        def = double.parse(tile.properties['def'] ?? '0'),
        poisonAtk = double.parse(tile.properties['poisonAtk'] ?? '0'),
        super.square(tile.size, tile.image) {
    onCreate();
  }

  BasicComponent(this.startX, this.startY, this.image)
      : initialLifePoints = double.infinity,
        super.square(componentSize, image) {
    onCreate();
  }

  @mustCallSuper
  void onCreate() {
    _lifePoints = initialLifePoints;
    x = startX;
    y = startY;
    game.add(this);
  }

  double get lifePoints => _lifePoints;

  // Function used to change life points
  void lifePointsDifference(double difference, {BasicComponent cause}) {
    _lifePoints += difference < 0 ? difference + def : difference;
    if (this == player) {
      double _percent = player.lifePoints / player.initialLifePoints;
      lifePointsBar.state.refresh(
        percent: _percent,
        text: 'LP: ' +
            (_percent.isFinite ? player.lifePoints.round().toString() : 'Max'),
        poison: player.poisonQuantity > 0,
      );
    }
    if (_lifePoints <= 0) {
      delete();
      if (this is! BasicStaticComponent) {
        cause?.killedEnemies++;
        cause?.experiencePoints += level;
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
  }

  // Delete component
  void delete() {
    remove = true;
  }

  @override
  bool destroy() => remove;
}
