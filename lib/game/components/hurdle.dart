import 'dart:ui';

import 'package:xeonjia/game/xeonjia.dart';

/// Component that can be bypassed only if coming from the allowed direction
class HurdleComponent extends BasicComponent {
  HurdleComponent(super.tile)
    : _allowedDirection = GetDirection.fromInt(
        int.parse(tile.properties['allowedDirection'] ?? '0'),
      ),
      super.fromTile();

  final Direction _allowedDirection;

  /// True if this can be bypassed by moving towards [direction]
  bool allows(Direction direction) => direction == _allowedDirection;

  @override
  Rect? collisionRect(Walker otherComponent) {
    return (otherComponent.direction == _allowedDirection ||
            otherComponent.direction!.dx * (otherComponent.x - x) > 0 ||
            otherComponent.direction!.dy * (otherComponent.y - y) > 0)
        ? null
        : super.collisionRect(otherComponent);
  }
}
