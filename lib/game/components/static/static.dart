import 'dart:ui';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Static component
class StaticComponent extends BasicComponent {
  // If true: other components can walk on this, else: this is a solid component
  final bool _walkable;
  StaticComponent(tile, {bool walkable = false})
      : _walkable = walkable,
        super.fromTile(tile);

  @override
  Rect collisionRect(DynamicComponent otherComponent) {
    if (!_walkable) return super.collisionRect(otherComponent);
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
