import 'dart:math';
import 'package:flame/animation.dart' as flame_animation;
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/basic_static.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/models/tile.dart';
import 'package:xeonjia/util/little_scheme.dart';

// Basic game component
// Every game component extends this one
abstract class BasicComponent extends SpriteComponent {
  // Component starting position
  Point startingPosition;

  // Component image file
  // Not used if it is instantiated by BasicComponent.fromTile()
  String image;
  double imageY;

  // Initial life points
  double initialLifePoints = double.infinity;

  // Component level
  int level = 0;

  // Experience points gained during match
  int experiencePoints = 0;

  // Current life points
  // Value edited by using lifePointsDifference() method
  double _lifePoints;
  double get lifePoints => _lifePoints;

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

  // Check if this is player one (a player can only be a CharacterComponent)
  bool get isPlayerOne => false;

  // Sprite animation
  flame_animation.Animation animation;

  // True if this is doing the deletion animation
  bool isBeingDeleted = false;

  // Actions executed by the component
  String action = '';
  String eventChange = '';

  BasicComponent.fromTile(Tile tile)
      : startingPosition = tile.position,
        action = tile.properties['action'] ?? '',
        eventChange = tile.properties['eventChange'] ?? '',
        initialLifePoints =
            double.parse(tile.properties['lifePoints'] ?? 'Infinity'),
        atk = double.parse(tile.properties['atk'] ?? '0'),
        def = double.parse(tile.properties['def'] ?? '0'),
        poisonAtk = double.parse(tile.properties['poisonAtk'] ?? '0'),
        super.fromSprite(tile.size, tile.size, tile.sprite) {
    onCreate();
  }

  BasicComponent(this.startingPosition, this.image, {this.imageY = 0})
      : initialLifePoints = double.infinity,
        super.fromSprite(
          componentSize,
          componentSize,
          Sprite(image, width: 16, height: 16, y: 16.0 * imageY),
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
    eventChanged();
  }

  @mustCallSuper
  void playAction(Direction orientation) {
    if (action == '') return;
    game.environment
        .defineSymbol(Sym('self'), Intrinsic('self', 0, (Cell x) => this));
    evaluate(readFromTokens(splitStringIntoTokens(action)), game.environment);
  }

  // Execute eventChange property
  void eventChanged() {
    if (eventChange == '') return;
    game.environment
        .defineSymbol(Sym('self'), Intrinsic('self', 0, (Cell x) => this));
    evaluate(
        readFromTokens(splitStringIntoTokens(eventChange)), game.environment);
  }

  // Update LP and poison quantity
  void status(double lifePoints, double poison) {
    _lifePoints = lifePoints;
    poison = poison;
  }

  // Function used to change life points
  void lifePointsDifference(double difference,
      {BasicComponent cause, double poison = 0}) {
    if (game.config.friendlyFire || teamId != (cause?.teamId ?? -99)) {
      _lifePoints += difference < 0 ? difference + def : difference;
      poisonQuantity += poison;
      if (isPlayerOne && difference != 0) {
        game.refreshLifePointsBar();
      }
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

  // True if this component is flying
  bool isFlying() => false;

  // Collision area
  Rect collisionRect(DynamicComponent otherComponent) => toRect();

  // True if this component could be collided
  // It depends on component that would collide this one
  bool isSolid({@required DynamicComponent otherComponent}) => true;

  // Define what happens if this component has been overlapped by another one
  // Used if isSolid() returned false
  void overlappedBy(DynamicComponent componentAbove) {}

  // Reset life points
  void restoreLifePoints() {
    _lifePoints = initialLifePoints;
    if (isPlayerOne) game.refreshLifePointsBar();
  }

  // Animate this component
  void animate(List<Sprite> sprites) {
    animation = flame_animation.Animation.spriteList(sprites,
        stepTime: 0.15, loop: false);
  }

  @override
  void update(double dt) {
    animation?.update(dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (animation?.done() ?? true) {
      super.render(canvas);
    } else {
      prepareCanvas(canvas);
      animation.getSprite().render(canvas,
          width: width, height: height, overridePaint: overridePaint);
    }
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
