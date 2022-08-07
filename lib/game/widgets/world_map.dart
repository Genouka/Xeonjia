import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:xeonjia/game/models/map_data.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// World map
class WorldMap extends SpriteComponent with HasGameRef<XeonjiaGame> {
  @override
  Future<void>? onLoad() {
    priority = 9999;
    sprite = Sprite(Flame.images.fromCache('map.png'));
    size = Vector2(gameRef.map.width * componentSize,
        gameRef.map.width * componentSize * 0.7);
    addAll(worldData
        .where((m) => !m.hidden && mainCharacter.visitedRooms.contains(m.id))
        .map(_RectangleMap.new));
    return super.onLoad();
  }

  MapData? selectedMap;
}

// A single map
class _RectangleMap extends PositionComponent
    with HasGameRef<XeonjiaGame>, Tappable {
  _RectangleMap(this.map);
  final MapData map;
  bool isTheCurrentMap = false;

  @override
  Future<void>? onLoad() {
    isTheCurrentMap = map.id == gameRef.map.id;
    return super.onLoad();
  }

  @override
  bool onTapUp(TapUpInfo info) {
    (parent as WorldMap).selectedMap = map;
    if (map.id == gameRef.map.id) {
      gameRef.setMessage(Message(gameRef, 'This is where I am right now.'.i18n,
          translate: false));
      return true;
    }
    if (map.text != null) gameRef.setMessage(Message(gameRef, map.text!));
    // i18n: "Do you want to come back to this place?".i18n
    // i18n: "* {{hero}} has arrived here *".i18n
    gameRef.executeAction(action: '''
(begin
    (dialog '(("Do you want to come back to this place?")))
    (define id "generic-question")
    (answer id '(("Yes" . #t) ("No" . #f)))
    (wait)
    (if (get id)
        (begin
            (dialog '(("* After a long journey, {{hero}} has arrived here *")))
            (teleport "${map.id}" #t))))''');
    return true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final double multiplier =
        (parent as WorldMap).size.x * MapData.offset.x * MapData.scale;
    final Vector2 offset = Vector2.copy((parent as WorldMap).size)
      ..multiply(MapData.offset);
    position = Vector2(map.x * multiplier, map.y * multiplier) + offset;
    this.size = Vector2(map.width * multiplier, map.height * multiplier);
  }

  final Paint mapPaint = Paint()
    ..color = const Color(0xFF0909FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint currentMapPaint = Paint()
    ..color = const Color(0xFFFF0909)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint selectedMapPaint = Paint()
    ..color = const Color(0xFFD47612)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    if ((parent as WorldMap).selectedMap == map) {
      canvas.drawRect(
          Rect.fromLTWH(1, 1, width - 2, height - 2), selectedMapPaint);
    } else if (isTheCurrentMap) {
      canvas.drawRect(
          Rect.fromLTWH(1, 1, width - 2, height - 2), currentMapPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), mapPaint);
    }
  }
}
