import 'dart:ui';

import 'package:xeonjia/game/xeonjia.dart';

/// Direction changer component
/// Change the direction of the components that walk over this
class DirectionChangerComponent extends BasicComponent {
  DirectionChangerComponent(tile)
      : _forcedDirection = GetDirection.fromInt(
            int.parse(tile.properties['forcedDirection'] ?? '0')),
        super.fromTile(tile);
  final Direction _forcedDirection;

  @override
  int get priority => 20;

  @override
  void collidedBy(Walker otherComponent, [bool wasStationary = false]) {
    otherComponent.updateDirection(_forcedDirection,
        forced: true, animated: false);
  }

  @override
  Rect? collisionRect(Walker otherComponent) => otherComponent.isFlying() ||
          otherComponent.wasStationary ||
          otherComponent.direction == _forcedDirection
      ? null
      : oppositeBorderRect(otherComponent);
}
