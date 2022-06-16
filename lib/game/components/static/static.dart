import 'dart:ui';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';

// Static component
class StaticComponent extends BasicComponent {
  StaticComponent(tile, {bool walkable = false})
      : _slippery = (tile.properties['slippery'] ?? 'false') == 'true',
        _walkable = walkable,
        super.fromTile(tile);

  // If true: other components slide on this
  final bool _slippery;

  // If true: other components can walk on this
  final bool _walkable;
  bool get isFloor => _walkable;

  @override
  Rect? collisionRect(DynamicComponent otherComponent) {
    if (_slippery) return null;
    if (!_walkable) return super.collisionRect(otherComponent);
    if (otherComponent.isFlying() != isFlying() ||
        otherComponent.wasStationary) {
      return null;
    }
    return oppositeBorderRect(otherComponent);
  }
}
