import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:xeonjia/game/models/map_data.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// World map
class WorldMap extends SpriteComponent with HasGameRef<XeonjiaGame> {
  @override
  Future<void>? onLoad() {
    priority = 9999;
    sprite = Sprite(Flame.images.fromCache('map.png'));
    size = Vector2(gameRef.map.width * componentSize,
        gameRef.map.width * componentSize * 0.7);
    addAll(worldData.map(_RectangleMap.new));
    return super.onLoad();
  }

  String selectedMap = '';
}

// A single map
class _RectangleMap extends PositionComponent
    with HasGameRef<XeonjiaGame>, Tappable {
  _RectangleMap(this.map);
  final MapData map;
  bool isTheCurrentMap = false;

  @override
  Future<void>? onLoad() {
    isTheCurrentMap = map.fileName.split('.').first == gameRef.map.id;
    return super.onLoad();
  }

  @override
  bool onTapUp(TapUpInfo info) {
    (parent as WorldMap).selectedMap = map.fileName;
    return true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(map.x, map.y) * MapData.scale + MapData.offset;
    this.size = Vector2(map.width, map.height) * MapData.scale;
  }

  final Paint mapPaint = Paint()
    ..color = const Color(0xFF0909FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint currentMapPaint = Paint()
    ..color = const Color(0xFFFF0909)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    isTheCurrentMap
        ? canvas.drawRect(
            Rect.fromLTWH(2, 2, width - 4, height - 4), currentMapPaint)
        : canvas.drawRect(Rect.fromLTWH(0, 0, width, height), mapPaint);
  }
}
