import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:meta/meta.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/snowball.dart';
import 'package:xeonjia/game/components/static/static.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/models/tile.dart';

// Basic game component
// Every game component extends this one
abstract class BasicComponent extends SpriteComponent {
  BasicComponent(
      int? id, Point startingPosition, Map<String, dynamic> properties)
      : this.fromTile(Tile(
            id: id,
            position: startingPosition,
            size: componentSize,
            sprite: Sprite(Flame.images.fromCache(properties['image']),
                srcSize: Vector2.all(16) * (properties['imageY'] ?? 0)),
            properties: properties));

  BasicComponent.fromTile(Tile tile)
      : id = tile.id,
        startingPosition = tile.position!,
        name = tile.properties['name'],
        action = tile.properties['action'] ?? '',
        actionOnCollision = tile.properties['actionOnCollision'] ?? '',
        actionOnEvent = tile.properties['actionOnEvent'] ?? '',
        maxLifePoints =
            double.parse(tile.properties['lifePoints'] ?? 'Infinity'),
        atk = double.parse(tile.properties['atk'] ?? '0'),
        def = double.parse(tile.properties['def'] ?? '0'),
        poisonAtk = double.parse(tile.properties['poisonAtk'] ?? '0'),
        _visible = 'true' == (tile.properties['visible'] ?? 'true'),
        _flying = 'true' == (tile.properties['flying'] ?? 'false'),
        _layerPriority = 100 * (tile.layer ?? 0),
        _customPriority = int.parse(tile.properties['priority'] ?? '0'),
        image = tile.properties['image'] ?? '',
        imageY = tile.properties['imageY'] ?? 0,
        super(
          size: Vector2(tile.size!, tile.size!),
          sprite: tile.sprite,
        ) {
    animate(tile.animationSprites,
        stepTime: tile.animationStepTime, loop: true);
    onCreate();
  }

  // Component unique ID
  final int? id;

  // Component starting position
  Point startingPosition;

  // Component image file
  String image;
  double imageY;

  // Initial life points
  double maxLifePoints = double.infinity;

  // Current life points
  // Value edited by using lifePointsDifference() method
  late double _lifePoints;
  double get lifePoints => _lifePoints;

  // Poison released to enemies during collision
  double poisonAtk = 0;

  // Poison in this component
  // It reduce life points when move
  double poisonQuantity = 0;

  // Enemies defeated by this component
  int defeatedEnemies = 0;

  // Number of times this component has been defeated
  int defeats = 0;

  // Player points (100 points for each CharacterComponents defeated)
  int points = 0;

  // Amount of damage done on collision
  double atk = 0;

  // Amount of protected damage
  double def = 0;

  // Direction values
  // They equal to zero if the component is not moving
  Direction? direction;

  // True if rendered
  bool _visible = true;
  bool get isVisible => _visible;
  void hide() => _visible = false;
  void show() => _visible = true;
  void invertVisibility() => _visible = !_visible;

  // True if this is not on the ground floor
  bool _flying = false;

  // Component priority
  int _customPriority = 0;

  // Priority based on tile's layer
  int _layerPriority = 0;

  // True if this component has to be removed from game
  bool deleted = false;

  // Component that generated this one
  // A component can't collide with its father
  // Mainly used for weapon shot
  BasicComponent? father;

  // This component's team
  // It is used to avoid friendly fire among components of the same species
  // It is also used in multiplayer matches to manage team membership
  int teamId = -1;
  Team get team => game!.teams!.firstWhere((team) => team.id == teamId);

  // Check if this is player one (a player can only be a CharacterComponent)
  bool get isPlayerOne => false;

  // Sprite animation
  SpriteAnimation? animation;

  // True if this is doing the deletion animation
  bool isBeingDeleted = false;

  // Actions executed by the component
  String action = ''; // when inspected
  String actionOnCollision = ''; // when collided
  String actionOnEvent = ''; // when the map is loaded or a new event is fired

  // Component default name (eg. girl, man, hero, old-man)
  String? name;

  @mustCallSuper
  void onCreate() {
    _lifePoints = maxLifePoints;
    x = startingPosition.x * componentSize;
    y = startingPosition.y * componentSize;
    game!.add(this);
    if (this is! SnowballComponent) executeAction();
  }

  // Execute an action
  void executeAction([String? action, BasicComponent? actor]) {
    game!.executeAction(
        action: action ?? actionOnEvent, actor: actor ?? this, self: this);
  }

  @mustCallSuper
  void playAction(Direction orientation) {
    executeAction(action);
  }

  // Update LP and poison quantity
  void setStatus(double lifePoints, double poison) {
    _lifePoints = lifePoints;
    poisonQuantity = poison;
    game!.refreshLifePointsBar();
  }

  // Restore LP and poison quantity
  void restoreStatus() {
    _lifePoints = maxLifePoints;
    poisonQuantity = 0;
    game!.refreshLifePointsBar();
  }

  // Function used to change life points
  void lifePointsDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if ((game!.config.mode != GameMode.story || game!.config.friendlyFire) ||
        teamId != (cause?.teamId ?? -99)) {
      _lifePoints += difference < 0 ? min(0, difference + def) : difference;
      poisonQuantity += poison;
      if (_lifePoints < 0) _lifePoints = 0;
      if (_lifePoints > maxLifePoints) _lifePoints = maxLifePoints;
      if (isPlayerOne && difference != 0) {
        game!.refreshLifePointsBar();
      }
      if (_lifePoints <= 0) {
        delete();
        if (teamId == (cause?.teamId ?? -99)) {
          // Teammate defeated
          for (final team in game!.teams!) {
            if (team.id != teamId) team.basisPoints += 10;
          }
        } else if (this is! StaticComponent) {
          cause?.defeatedEnemies++;
          if (this is CharacterComponent) cause?.points += 100;
        }
      }
    }
  }

  // True if this component is flying
  bool isFlying() => _flying;

  @override
  int get priority => _customPriority != 0
      ? _customPriority
      : (_layerPriority + (_flying ? 50 : 0));

  // Collision area
  Rect? collisionRect(DynamicComponent otherComponent) => toRect();

  // Collision border based on otherComponent direction
  // It is used if otherComponent should stop on this
  Rect? oppositeBorderRect(DynamicComponent otherComponent) {
    // If the other component is going left or right
    if (otherComponent.direction?.dx != 0) {
      // If otherComponent.center > this.center -> do nothing
      // Else return a rect with width = 1 at the left or right of this
      return otherComponent.direction!.dx * (otherComponent.x - x) > 0
          ? null
          : Rect.fromLTWH(x + (otherComponent.direction!.dx > 0 ? width : -1),
              y, 1, height);
    } else {
      // (going up or down)
      // If otherComponent.center > this.center -> do nothing
      // Else return a rect with height = 1 at the top or bottom of this
      return otherComponent.direction!.dy * (otherComponent.y - y) > 0
          ? null
          : Rect.fromLTWH(x,
              y + (otherComponent.direction!.dy > 0 ? height : -1), width, 1);
    }
  }

  // True if this component could be collided
  // It depends on component that would collide this one
  bool isSolid({required DynamicComponent otherComponent}) => true;

  // Define what happens if this component has been overlapped by another one
  // Used if isSolid() returned false
  void overlappedBy(DynamicComponent componentAbove) {}

  // Define what happens if this component has been collided by another one
  void collidedBy(DynamicComponent otherComponent) {
    otherComponent.lifePointsDifference(-atk, cause: this, poison: poisonAtk);
    if (otherComponent.isPlayerOne) {
      executeAction(actionOnCollision, otherComponent);
    }
  }

  // Reset life points
  void restoreLifePoints() {
    _lifePoints = maxLifePoints;
    if (isPlayerOne) game!.refreshLifePointsBar();
  }

  // Animate this component
  void animate(List<Sprite> sprites, {double? stepTime, bool loop = false}) {
    if (sprites.isEmpty) return;
    animation = SpriteAnimation.spriteList(sprites,
        stepTime: stepTime ?? 15, loop: loop);
  }

  @override
  void update(double dt) {
    animation?.update(dt);
    super.update(dt);
  }

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    if (!_visible) return;
    if (animation?.done() ?? true) {
      super.render(canvas);
    } else {
      animation!.getSprite().render(canvas, size: Vector2(width, height));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    var ratio = componentSize / width;
    width = componentSize;
    height = componentSize;
    x *= ratio;
    y *= ratio;
    super.onGameResize(size);
  }

  // Delete component
  void delete() {
    ++defeats;
    game!.deletedComponents.add(this);
    removeChildren();
    deleted = true;
    game!.remove(this);
  }

  // Delete every son of this component
  void removeChildren() {
    for (final c in game!.children) {
      if (c is BasicComponent && c.father == this) c.delete();
    }
  }

  // Respawn component
  @mustCallSuper
  void respawn() {
    deleted = false;
    isBeingDeleted = false;
    restoreLifePoints();
    x = startingPosition.x * componentSize;
    y = startingPosition.y * componentSize;
    if (!game!.children.contains(this)) game!.add(this);
  }
}
