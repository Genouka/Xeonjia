import 'dart:ui';

import 'package:flame/components.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Reflection on ice
class IceReflection extends PositionComponent
    with HasGameReference<XeonjiaGame> {
  IceReflection(this.component);
  final BasicComponent component;
  final Paint paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.075);

  @override
  int priority = -998;

  bool get _hidden =>
      !component.isVisible ||
      game.worldMapEnabled ||
      component.y > game.map.height * componentSize - 2 * componentSize;

  @override
  void render(Canvas canvas) {
    if (_hidden) return;
    if (game.miniMapEnabled) {
      component.sprite?.render(
        canvas
          ..scale(game.miniMapZoom, -game.miniMapZoom)
          ..translate(
            component.x,
            -component.y -
                2 * component.height -
                (component is RenderOffset
                    ? (component as RenderOffset).offsetYIgnoreZoom
                    : 0),
          ),
        size: component.size,
        overridePaint: paint,
      );
    } else {
      if (component.renderTranslateY != 0) {
        canvas.translate(0, component.renderTranslateY * component.height);
      }
      canvas
        ..scale(1, -1)
        ..translate(
          component.x,
          -component.y -
              2 * component.height -
              (component is RenderOffset
                  ? (component as RenderOffset).offsetY
                  : 0),
        );
      if (component.animationTicker?.done() ?? true) {
        component.sprite?.render(
          component.renderHeight == 1
              ? canvas
              : (canvas..scale(1, component.renderHeight)),
          size: component.size,
          overridePaint: paint,
        );
      } else {
        component.animationTicker!.getSprite().render(
          canvas,
          size: Vector2(
            component.width,
            component.renderHeight * component.height,
          ),
          overridePaint: paint,
        );
      }
    }
  }
}
