import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:meta/meta.dart';

import 'package:xeonjia/game/xeonjia.dart';

/// Basic game component
/// Every game component extends this one
abstract class BasicComponent extends SpriteComponent
    with HasGameRef<XeonjiaGame>, TextAnimation {
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

  BasicComponent.fromTile(this.tile)
      : id = tile.id,
        startingPosition = tile.position!,
        name = tile.properties['name'],
        atlasAsset = tile.properties['atlasAsset'],
        action = tile.properties['action'] ?? '',
        actionOnCollision = tile.properties['actionOnCollision'] ?? '',
        actionOnEvent = tile.properties['actionOnEvent'] ?? '',
        maxHP = double.parse(tile.properties['hp'] ?? 'Infinity'),
        level = int.parse(tile.properties['level'] ?? '0'),
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

  /// Component unique ID
  /// PlayerOne has ID = -1
  final int? id;

  /// Component's tile
  Tile tile;

  /// Component starting position
  Point startingPosition;

  /// Component image file
  String image;
  double imageY;

  /// Component's level
  late int level;

  /// Initial health points
  double maxHP = double.infinity;

  /// Current health points
  /// Value edited by using healthPointsDifference() method
  late double _hp;
  double get hp => _hp;

  /// Poison released to enemies during collision
  double poisonAtk = 0;

  /// Poison in this component
  /// It reduce health points when move
  double poisonQuantity = 0;

  /// Amount of damage done on collision
  double atk = 0;

  /// Amount of protected damage
  double def = 0;

  /// Direction values
  /// They equal to zero if the component is not moving
  Direction? direction;

  /// True if rendered
  bool _visible = true;
  bool get isVisible => _visible;
  void hide() => _visible = false;
  void show() => _visible = true;
  void invertVisibility() => _visible = !_visible;

  /// Render size and translation
  double renderHeight = 1;
  double renderTranslateY = 0;

  /// True if this is not on the ground floor
  bool _flying = false;

  /// Component priority
  int _customPriority = 0;

  /// Priority based on tile's layer
  int _layerPriority = 0;

  /// True if this component has to be removed from game
  bool deleted = false;

  /// Component that generated this one
  /// A component can't collide with its father
  /// Mainly used for weapon shot
  BasicComponent? father;

  /// This component's team
  /// It is used to avoid friendly fire among components of the same species
  int teamId = -1;

  /// Check if this is Component controlled by the user
  bool get isUser => teamId == 0;
  bool get isPlayerOne => this == gameRef.playerOne;

  /// Sprite animation
  SpriteAnimation? animation;

  /// True if this is doing the deletion animation
  bool isBeingDeleted = false;

  /// Actions executed by the component
  String action = ''; // when inspected
  String actionOnCollision = ''; // when collided
  String actionOnEvent = ''; // when the map is loaded or a new event is fired

  /// Component default name (eg. girl, man, hero, old-man)
  String? name;

  @override
  @mustCallSuper
  Future<void>? onLoad() async {
    _hp = maxHP;
    if (this is! SnowballComponent) executeAction();
    sprite ??= Sprite(Flame.images.fromCache('basic.png')); // placeholder
    if (atlasAsset != null && name != null) {
      atlas = await gameRef.loadCustomAtlas('images/metadata/$atlasAsset');
      sprite = getSpriteFromAtlas();
      if ('true' == (tile.properties['visible'] ?? 'true')) show();
    }
  }

  /// Atlas file used for sprites and animations
  String? atlasAsset;
  late FireAtlas atlas;
  Sprite getSpriteFromAtlas() => atlas.getSprite(name!);

  /// Reflection on ice
  IceReflection? reflection;

  /// Execute an action
  void executeAction([String? action, BasicComponent? actor]) {
    gameRef.executeAction(
        action: action ?? actionOnEvent, actor: actor ?? this, self: this);
  }

  @mustCallSuper
  void playAction(Direction orientation) => executeAction(action);

  /// Update HP and poison quantity
  void setStatus(double hp, double poison) {
    _hp = hp;
    poisonQuantity = poison;
    gameRef.refreshHPBar();
  }

  /// Restore HP and poison quantity
  void restoreStatus() {
    _hp = maxHP;
    poisonQuantity = 0;
    gameRef.refreshHPBar();
  }

  /// Function used to change health points
  void hpDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if (teamId != (cause?.teamId ?? -99)) {
      double actual = difference < 0 ? min(0, difference + def) : difference;
      _hp += actual;
      if (actual != 0 && maxHP.isFinite) {
        showText(actual.round().toString());
        if (isUser && actual < 0) gameRef.playSound(Sfx.damage, volume: 1);
      }
      poisonQuantity += poison;
      if (_hp < 0) _hp = 0;
      if (_hp > maxHP) _hp = maxHP;
      if (isUser && difference != 0) gameRef.refreshHPBar();
      if (_hp <= 0) {
        if (name == 'king-of-evil' && gameRef.enemies > 1) {
          _hp = 1;
          gameRef.setMessage(Message(
            gameRef,
            "You can't defeat me as long as there are other monsters besides me."
                .i18n,
            author: '/king-of-evil',
            translate: false,
          ));
          return;
        }
        delete();
      }
    }
  }

  /// True if this component is flying
  bool isFlying() => _flying;

  @override
  int get priority => _customPriority != 0
      ? _customPriority
      : (_layerPriority + (_flying ? 50 : 0));

  /// Collision area
  Rect? collisionRect(Walker otherComponent) => toRect();

  /// Collision border based on otherComponent direction
  /// It is used if otherComponent should stop on this
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

  /// True if this component could be collided (otherwise it is overlapped)
  /// It depends on component that would collide this one
  bool isSolid({required Walker otherComponent}) => !isBeingDeleted;

  /// Define what happens if this component has been overlapped by another one
  /// Used if isSolid() returned false
  void overlappedBy(Walker componentAbove) {}

  /// Define what happens if this component has been collided by another one
  // ignore: avoid_positional_boolean_parameters
  void collidedBy(Walker otherComponent, [bool wasStationary = false]) {
    if (!wasStationary) {
      otherComponent.hpDifference(-atk, cause: this, poison: poisonAtk);
    }
    if (otherComponent.isUser) executeAction(actionOnCollision, otherComponent);
  }

  /// Reset health points
  void restoreHP() => _hp = maxHP;

  @override
  void update(double dt) {
    animation?.update(dt);
    super.update(dt);
  }

  @override
  Paint paint = Paint()..isAntiAlias = false;

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    if (!_visible || gameRef.worldMapEnabled) return;
    if (gameRef.miniMapEnabled) {
      canvas
        ..translate(position.x * gameRef.miniMapZoom - position.x,
            position.y * gameRef.miniMapZoom - position.y)
        ..scale(gameRef.miniMapZoom);
    }
    if (renderTranslateY != 0) canvas.translate(0, -renderTranslateY * height);
    animation?.done() ?? true
        ? super.render(
            renderHeight == 1 ? canvas : (canvas..scale(1, renderHeight)))
        : animation!
            .getSprite()
            .render(canvas, size: Vector2(width, renderHeight * height));
    showTextAnimation(canvas);
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

  /// Delete component
  /// Silently: don't execute [XeonjiaGame.map.action] and [deletionAnimation]
  void delete({bool silently = false}) {
    gameRef.deletedComponents.add(this);
    removeChildren();
    deleted = true;
    gameRef.remove(this);
    if (reflection != null) gameRef.remove(reflection!);
  }

  /// Delete every son of this component
  void removeChildren() {
    for (final c in gameRef.children) {
      if (c is BasicComponent && c.father == this) c.delete();
    }
  }

  /// Respawn component
  @mustCallSuper
  void respawn(XeonjiaGame gameRef) {
    deleted = false;
    isBeingDeleted = false;
    restoreHP();
    x = startingPosition.x * componentSize;
    y = startingPosition.y * componentSize;
    if (!gameRef.children.contains(this)) gameRef.add(this);
    if (reflection != null && !gameRef.children.contains(reflection)) {
      gameRef.add(reflection!);
    }
  }
}
