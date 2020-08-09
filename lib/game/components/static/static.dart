import 'dart:ui';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Static component
class StaticComponent extends BasicComponent {
  // If true: other components slide on this
  final bool _slippery;

  // If true: other components can walk on this
  final bool _walkable;
  StaticComponent(tile, {bool walkable = false})
      : _slippery = (tile.properties['slippery'] ?? 'false') == 'true',
        _walkable = walkable,
        super.fromTile(tile);

  @override
  Rect collisionRect(DynamicComponent otherComponent) {
    if (_slippery) return null;
    if (!_walkable) return super.collisionRect(otherComponent);
    if (otherComponent.isFlying() != isFlying() ||
        otherComponent.wasStationary) {
      return null;
    }
    // If the other component is going left or right
    if (otherComponent.direction.dx != 0) {
      // If otherComponent.center > this.center -> do nothing
      // Else return a rect with width = 1 at the left or right of this
      return otherComponent.direction.dx * (otherComponent.x - x) > 0
          ? null
          : Rect.fromLTWH(
              x + (otherComponent.direction.dx > 0 ? width : -1), y, 1, height);
    } else {
      // (going up or down)
      // If otherComponent.center > this.center -> do nothing
      // Else return a rect with height = 1 at the top of bottom of this
      return otherComponent.direction.dy * (otherComponent.y - y) > 0
          ? null
          : Rect.fromLTWH(
              x, y + (otherComponent.direction.dy > 0 ? height : -1), width, 1);
    }
  }
}
