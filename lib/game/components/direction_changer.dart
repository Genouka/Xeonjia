import 'dart:ui';

import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/utils/direction.dart';

// Direction changer component
// Change the direction of the components that walk over this
class DirectionChangerComponent extends BasicComponent {
  DirectionChangerComponent(tile)
      : _forcedDirection = GetDirection.fromInt(
            int.parse(tile.properties['forcedDirection'] ?? '0')),
        super.fromTile(tile);
  final Direction _forcedDirection;

  @override
  void collidedBy(Walker otherComponent) {
    otherComponent.updateDirection(_forcedDirection, forced: true);
  }

  @override
  Rect? collisionRect(Walker otherComponent) => otherComponent.isFlying() ||
          otherComponent.wasStationary ||
          otherComponent.direction == _forcedDirection
      ? null
      : oppositeBorderRect(otherComponent);
}
