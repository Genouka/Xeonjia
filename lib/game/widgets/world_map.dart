import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// World map
class WorldMap extends SpriteComponent with HasGameReference<XeonjiaGame> {
  @override
  FutureOr<void> onLoad() {
    priority = 9999;
    sprite = Sprite(Flame.images.fromCache('map.png'));
    addAll(
      worldData
          .where(
            (m) =>
                !m.hidden &&
                mainCharacter.visitedRooms.any(
                  (e) => e.split('/').first == m.id,
                ),
          )
          .map(_RectangleMap.new),
    );
    this.add(pointer);
    return super.onLoad();
  }

  Pointer pointer = Pointer();
  void movePointer(Direction direction) {
    if (!pointer.visible) {
      pointer.visible = true;
      pointer.x = (-position.x + game.size.x / 2) / game.miniMapZoom;
      pointer.y = (-position.y + game.size.y / 2) / game.miniMapZoom;
    }
    switch (direction) {
      case Direction.down:
        pointer.y = min(pointer.y + pointer.delta, size.y);
        break;
      case Direction.up:
        pointer.y = max(pointer.y - pointer.delta, 0);
        break;
      case Direction.right:
        pointer.x = min(pointer.x + pointer.delta, size.x);
        break;
      case Direction.left:
        pointer.x = max(pointer.x - pointer.delta, 0);
        break;
    }
    _pan(pointer.x, pointer.y);
  }

  void _pan(double worldX, double worldY) {
    position = Vector2(
      -game.moveCamera(game.size.x, worldMapWidth, worldX * game.miniMapZoom),
      -game.moveCamera(game.size.y, worldMapHeight, worldY * game.miniMapZoom),
    );
  }

  void selectPoint([Vector2? at]) {
    var p = (at ?? pointer.position) * game.miniMapZoom;
    (children.firstWhereOrNull(
      (m) => m is _RectangleMap && m.containsPoint(p),
    ) as _RectangleMap?)?.selected();
  }

  @override
  Paint paint = Paint()..isAntiAlias = false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(
      worldMapWidth * componentSize * game.miniMapZoom,
      worldMapHeight * componentSize * game.miniMapZoom,
    );
    _updateCamera();
  }

  @override
  void render(Canvas canvas) {
    canvas.scale(game.miniMapZoom);
    super.render(canvas);
  }

  /// Update [game.camera.position] based on currentMap
  void _updateCamera() {
    if (_currentMapPosition != null && game.elapsed != 0) {
      position = Vector2(
        -game.moveCamera(game.size.x, worldMapWidth, _currentMapPosition!.x),
        -game.moveCamera(game.size.y, worldMapHeight, _currentMapPosition!.y),
      );
    }
  }

  void reclampPosition([double? previousZoom]) {
    double centerX, centerY;
    if (pointer.visible) {
      centerX = pointer.x * game.miniMapZoom;
      centerY = pointer.y * game.miniMapZoom;
    } else {
      final zoomRatio = previousZoom == null
          ? 1.0
          : game.miniMapZoom / previousZoom;
      centerX = (-position.x + game.size.x / 2) * zoomRatio;
      centerY = (-position.y + game.size.y / 2) * zoomRatio;
    }
    position = Vector2(
      -game.moveCamera(game.size.x, worldMapWidth, centerX),
      -game.moveCamera(game.size.y, worldMapHeight, centerY),
    );
  }

  MapData? _selectedMap;
  Vector2? _currentMapPosition;
}

/// Pointer moved with keyboard
class Pointer extends PositionComponent with HasGameReference<XeonjiaGame> {
  @override
  FutureOr<void> onLoad() {
    size = Vector2(1, 1);
    return super.onLoad();
  }

  final Paint _paint = Paint()..color = Colors.red;
  int get delta => (game.size.toSize().shortestSide / 25).round();
  bool visible = false;

  @override
  void render(Canvas canvas) =>
      visible ? canvas.drawCircle(Offset.zero, 5, _paint) : null;
}

/// A single map
class _RectangleMap extends PositionComponent
    with HasGameReference<XeonjiaGame> {
  _RectangleMap(this.map);
  final MapData map;
  bool get isTheCurrentMap => map.id == game.map.id;

  bool selected() {
    if (game.messageManager.isActive) return true;
    (parent as WorldMap)._selectedMap = map;
    if (map.id == game.map.id) {
      game.setMessage(
        Message(game, 'This is where I am right now.'.i18n, translate: false),
      );
      return true;
    }
    if (map.text != null) game.setMessage(Message(game, map.text!));
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
    game.executeAction(
      action: '''
(begin
    (dialog '(("Do you want to go back to this place?")))
    (define id "generic-question")
    (answer id '(("Yes" . #t) ("No" . #f)))
    (wait)
    (if (get id) (teleport-with-dialog "${map.id}" "$text")))''',
    );
    return true;
  }

  @override
  bool containsPoint(Vector2 point) =>
      (point.x >= x * game.miniMapZoom) &&
      (point.y >= y * game.miniMapZoom) &&
      (point.x < x * game.miniMapZoom + size.x * game.miniMapZoom) &&
      (point.y < y * game.miniMapZoom + size.y * game.miniMapZoom);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    var parentSize = Vector2(
      worldMapWidth * componentSize * game.miniMapZoom,
      worldMapHeight * componentSize * game.miniMapZoom,
    );
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
        Rect.fromLTWH(1, 1, width - 2, height - 2),
        _selectedMapPaint,
      );
    } else if (isTheCurrentMap) {
      canvas.drawRect(
        Rect.fromLTWH(1, 1, width - 2, height - 2),
        _currentMapPaint,
      );
    }
  }
}
