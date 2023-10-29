import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// World map
class WorldMap extends SpriteComponent with HasGameRef<XeonjiaGame> {
  @override
  FutureOr<void> onLoad() {
    priority = 9999;
    sprite = Sprite(Flame.images.fromCache('map.png'));
    addAll(worldData
        .where((m) =>
            !m.hidden &&
            mainCharacter.visitedRooms.any((e) => e.split('/').first == m.id))
        .map(_RectangleMap.new));
    this.add(pointer);
    return super.onLoad();
  }

  Pointer pointer = Pointer();
  void movePointer(Direction direction) {
    pointer.visible = true;
    switch (direction) {
      case Direction.down:
        pointer.y = min(pointer.y + pointer.delta, position.y + size.y);
        break;
      case Direction.up:
        pointer.y = max(pointer.y - pointer.delta, position.x);
        break;
      case Direction.right:
        pointer.x = min(pointer.x + pointer.delta, position.x + size.x);
        break;
      case Direction.left:
        pointer.x = max(pointer.x - pointer.delta, position.x);
        break;
    }
    gameRef.camera.snapTo(Vector2(
        gameRef.moveCamera(
            gameRef.size.x, gameRef.map.width, pointer.x * gameRef.miniMapZoom),
        gameRef.moveCamera(gameRef.size.y, gameRef.map.width * 0.7,
            pointer.y * gameRef.miniMapZoom)));
  }

  void selectPoint() {
    (children.firstWhereOrNull((m) =>
                m is _RectangleMap &&
                m.containsPoint(pointer.position * gameRef.miniMapZoom))
            as _RectangleMap?)
        ?.selected();
  }

  @override
  Paint paint = Paint()..isAntiAlias = false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(gameRef.map.width * componentSize * gameRef.miniMapZoom,
        gameRef.map.width * componentSize * gameRef.miniMapZoom * 0.7);
    _updateCamera();
  }

  @override
  void render(Canvas canvas) {
    canvas.scale(gameRef.miniMapZoom);
    super.render(canvas);
  }

  /// Update [gameRef.camera.position] based on currentMap
  void _updateCamera() {
    if (_currentMapPosition != null && gameRef.elapsed != 0) {
      gameRef.updateCamera(_currentMapPosition!.x, _currentMapPosition!.y);
    }
  }

  MapData? _selectedMap;
  Vector2? _currentMapPosition;
}

/// Pointer moved with keyboard
class Pointer extends PositionComponent with HasGameRef<XeonjiaGame> {
  @override
  FutureOr<void> onLoad() {
    x = gameRef.camera.position.x + gameRef.size.x / 2;
    y = gameRef.camera.position.y + gameRef.size.y / 2;
    size = Vector2(1, 1);
    return super.onLoad();
  }

  final Paint _paint = Paint()..color = Colors.red;
  int get delta => (gameRef.size.toSize().shortestSide / 25).round();
  bool visible = false;

  @override
  void render(Canvas canvas) =>
      visible ? canvas.drawCircle(Offset.zero, 5, _paint) : null;
}

/// A single map
class _RectangleMap extends PositionComponent
    with HasGameRef<XeonjiaGame>, Tappable {
  _RectangleMap(this.map);
  final MapData map;
  bool get isTheCurrentMap => map.id == gameRef.map.id;

  @override
  bool onTapUp(TapUpInfo info) => selected();
  bool selected() {
    if (gameRef.messageManager.isActive) return true;
    (parent as WorldMap)._selectedMap = map;
    if (map.id == gameRef.map.id) {
      gameRef.setMessage(Message(gameRef, 'This is where I am right now.'.i18n,
          translate: false));
      return true;
    }
    if (map.text != null) gameRef.setMessage(Message(gameRef, map.text!));
    // i18n: "Do you want to go back to this place?".i18n
    // i18n: "* {{hero}} arrived here *".i18n
    // i18n: "* After a long journey, {{hero}} arrived here *".i18n
    // i18n: "* After a very long journey, {{hero}} arrived here *".i18n
    var distance =
        (parent as WorldMap)._currentMapPosition!.distanceTo(position) /
            (parent as WorldMap).size.x;
    var text = distance < 0.2
        ? '* {{hero}} arrived here *'
        : (distance < 0.3
            ? '* After a long journey, {{hero}} arrived here *'
            : '* After a very long journey, {{hero}} arrived here *');
    gameRef.executeAction(action: '''
(begin
    (dialog '(("Do you want to go back to this place?")))
    (define id "generic-question")
    (answer id '(("Yes" . #t) ("No" . #f)))
    (wait)
    (if (get id) (teleport-with-dialog "${map.id}" "$text")))''');
    return true;
  }

  @override
  bool containsPoint(Vector2 point) =>
      (point.x >= x * gameRef.miniMapZoom) &&
      (point.y >= y * gameRef.miniMapZoom) &&
      (point.x < x * gameRef.miniMapZoom + size.x * gameRef.miniMapZoom) &&
      (point.y < y * gameRef.miniMapZoom + size.y * gameRef.miniMapZoom);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    var parentSize = Vector2(
        gameRef.map.width * componentSize * gameRef.miniMapZoom,
        gameRef.map.width * componentSize * gameRef.miniMapZoom * 0.7);
    final double multiplier = parentSize.x * MapData.offset.x * MapData.scale;
    final Vector2 offset = Vector2.copy(parentSize)..multiply(MapData.offset);
    position = Vector2(map.x * multiplier, map.y * multiplier) + offset;
    this.size = Vector2(map.width * multiplier, map.height * multiplier);
    if (isTheCurrentMap) {
      (parent as WorldMap)
        .._currentMapPosition = position
        .._updateCamera();
    }
  }

  final Paint _currentMapPaint = Paint()
    ..color = const Color(0xFFFF0909)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _selectedMapPaint = Paint()
    ..color = const Color(0xFFD47612)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    if ((parent as WorldMap)._selectedMap == map) {
      canvas.drawRect(
          Rect.fromLTWH(1, 1, width - 2, height - 2), _selectedMapPaint);
    } else if (isTheCurrentMap) {
      canvas.drawRect(
          Rect.fromLTWH(1, 1, width - 2, height - 2), _currentMapPaint);
    }
  }
}
