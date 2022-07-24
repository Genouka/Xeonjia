import 'dart:ui';

import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/utils/direction.dart';

// Component that can be bypassed only if coming from the allowed direction
class HurdleComponent extends BasicComponent {
  HurdleComponent(tile)
      : _allowedDirection = GetDirection.fromInt(
            int.parse(tile.properties['allowedDirection'] ?? '0')),
        super.fromTile(tile);

  final Direction _allowedDirection;

  @override
  Rect? collisionRect(Walker otherComponent) {
    return (otherComponent.direction == _allowedDirection ||
            otherComponent.direction!.dx * (otherComponent.x - x) > 0 ||
            otherComponent.direction!.dy * (otherComponent.y - y) > 0)
        ? null
        : super.collisionRect(otherComponent);
  }
}
