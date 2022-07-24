import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:meta/meta.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/snowball.dart';
import 'package:xeonjia/game/components/static/static.dart';
import 'package:xeonjia/game/util/fire_atlas.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/models/tile.dart';

// Basic game component
// Every game component extends this one
abstract class BasicComponent extends SpriteComponent
    with HasGameRef<XeonjiaGame> {
  BasicComponent(int? id, Point startingPosition,
      [Map<String, dynamic>? properties])
      : this.fromTile(Tile(
            id: id,
            position: startingPosition,
            size: componentSize,
            sprite: (properties?.containsKey('image') ?? false)
                ? Sprite(
                    Flame.images.fromCache(properties!['image']),
                    srcPosition:
                        Vector2(0, 16 * (properties['imageY'] as double? ?? 0)),
                    srcSize: Vector2.all(16),
                  )
                : null,
            properties: properties));

  BasicComponent.fromTile(Tile tile)
      : id = tile.id,
        startingPosition = tile.position!,
        name = tile.properties['name'],
        atlasAsset = tile.properties['atlasAsset'],
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
    if (tile.animationSprites.isNotEmpty) {
      animation = SpriteAnimation.spriteList(tile.animationSprites,
          stepTime: tile.animationStepTime ?? 0.15, loop: true);
    }
    if (tile.hidden) hide();
    x = startingPosition.x * componentSize;
    y = startingPosition.y * componentSize;
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
  Team get team => gameRef.teams!.firstWhere((team) => team.id == teamId);

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

  @override
  @mustCallSuper
  Future<void>? onLoad() async {
    _lifePoints = maxLifePoints;
    if (this is! SnowballComponent) executeAction();
    if (atlasAsset != null && name != null) {
      atlas = await gameRef.loadCustomAtlas('images/metadata/$atlasAsset');
      sprite = getSpriteFromAtlas();
      show();
    }
    sprite ??= Sprite(Flame.images.fromCache('basic.png')); // placeholder
  }

  // Atlas file used for sprites and animations
  String? atlasAsset;
  late FireAtlas atlas;
  Sprite getSpriteFromAtlas() => atlas.getSprite(name!);

  // Execute an action
  void executeAction([String? action, BasicComponent? actor]) {
    gameRef.executeAction(
        action: action ?? actionOnEvent, actor: actor ?? this, self: this);
  }

  @mustCallSuper
  void playAction(Direction orientation) => executeAction(action);

  // Update LP and poison quantity
  void setStatus(double lifePoints, double poison) {
    _lifePoints = lifePoints;
    poisonQuantity = poison;
    gameRef.refreshLifePointsBar();
  }

  // Restore LP and poison quantity
  void restoreStatus() {
    _lifePoints = maxLifePoints;
    poisonQuantity = 0;
    gameRef.refreshLifePointsBar();
  }

  // Function used to change life points
  void lifePointsDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if ((gameRef.config.mode != GameMode.story ||
            gameRef.config.friendlyFire) ||
        teamId != (cause?.teamId ?? -99)) {
      _lifePoints += difference < 0 ? min(0, difference + def) : difference;
      poisonQuantity += poison;
      if (_lifePoints < 0) _lifePoints = 0;
      if (_lifePoints > maxLifePoints) _lifePoints = maxLifePoints;
      if (isPlayerOne && difference != 0) {
        gameRef.refreshLifePointsBar();
      }
      if (_lifePoints <= 0) {
        delete();
        if (teamId == (cause?.teamId ?? -99)) {
          // Teammate defeated
          for (final team in gameRef.teams!) {
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
  Rect? collisionRect(Walker otherComponent) => toRect();

  // Collision border based on otherComponent direction
  // It is used if otherComponent should stop on this
  Rect? oppositeBorderRect(Walker otherComponent) {
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

  // True if this component could be collided (otherwise it is overlapped)
  // It depends on component that would collide this one
  bool isSolid({required Walker otherComponent}) => !isBeingDeleted;

  // Define what happens if this component has been overlapped by another one
  // Used if isSolid() returned false
  void overlappedBy(Walker componentAbove) {}

  // Define what happens if this component has been collided by another one
  void collidedBy(Walker otherComponent) {
    otherComponent.lifePointsDifference(-atk, cause: this, poison: poisonAtk);
    if (otherComponent.isPlayerOne) {
      executeAction(actionOnCollision, otherComponent);
    }
  }

  // Reset life points
  void restoreLifePoints() {
    _lifePoints = maxLifePoints;
    if (isPlayerOne) gameRef.refreshLifePointsBar();
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
    animation?.done() ?? true
        ? super.render(canvas)
        : animation!.getSprite().render(canvas, size: Vector2(width, height));
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
    gameRef.deletedComponents.add(this);
    removeChildren();
    deleted = true;
    gameRef.remove(this);
  }

  // Delete every son of this component
  void removeChildren() {
    for (final c in gameRef.children) {
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
    if (!gameRef.children.contains(this)) gameRef.add(this);
  }
}
