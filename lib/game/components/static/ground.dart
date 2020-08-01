import 'dart:ui';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Ground component
// Other components walk on this instead of sliding
class GroundComponent extends BasicComponent {
  // True if this is not on the ground floor
  final bool _flying;

  GroundComponent(tile)
      : _flying = 'true' == (tile.properties['flying'] ?? 'false'),
        super.fromTile(tile);

  @override
  bool isFlying() => _flying;

  @override
  int priority() => _flying ? 100 : 0;

  @override
  Rect collisionRect(DynamicComponent otherComponent) {
    if (otherComponent.isFlying() != isFlying() ||
        otherComponent.wasStationary) {
      return null;
    }
    if (otherComponent.direction.dx != 0) {
      return otherComponent.direction.dx * (otherComponent.x - x) > 0
          ? null
          : Rect.fromLTWH(
              x + (otherComponent.direction.dx > 0 ? width : -1), y, 1, height);
    } else {
      return otherComponent.direction.dy * (otherComponent.y - y) > 0
          ? null
          : Rect.fromLTWH(
              x, y + (otherComponent.direction.dy > 0 ? height : -1), width, 1);
    }
  }
}
