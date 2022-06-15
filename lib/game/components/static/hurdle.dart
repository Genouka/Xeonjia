import 'dart:ui';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Component that can be bypassed only if coming from the allowed direction
class HurdleComponent extends BasicComponent {
  HurdleComponent(tile)
      : _allowedDirection = GetDirection.fromInt(
            int.parse(tile.properties['allowedDirection'] ?? '0')),
        super.fromTile(tile);

  // Other components direction that permits to jump over this component
  final Direction _allowedDirection;

  @override
  Rect collisionRect(DynamicComponent otherComponent) {
    return (otherComponent.direction == _allowedDirection ||
            otherComponent.direction.dx * (otherComponent.x - x) > 0 ||
            otherComponent.direction.dy * (otherComponent.y - y) > 0)
        ? null
        : super.collisionRect(otherComponent);
  }
}
