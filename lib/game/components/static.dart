import 'dart:ui';

import 'package:xeonjia/game/xeonjia.dart';

/// Static component
class StaticComponent extends BasicComponent {
  StaticComponent(tile, {bool walkable = false})
      : _slippery = (tile.properties['slippery'] ?? 'false') == 'true',
        _walkable = walkable,
        hideable = (tile.properties['hideable'] ?? 'false') == 'true',
        super.fromTile(tile);

  /// If true: other components slide on this
  final bool _slippery;

  /// If true: other components can walk on this
  final bool _walkable;
  bool get isFloor => _walkable;

  /// If true: this component can be hidden from UI buttons (used for hints)
  final bool hideable;

  @override
  Rect? collisionRect(Walker otherComponent) {
    if (_slippery) return null;
    if (!_walkable) return super.collisionRect(otherComponent);
    if (otherComponent.isFlying() != isFlying() ||
        otherComponent.wasStationary) {
      return null;
    }
    return oppositeBorderRect(otherComponent);
  }

  @override
  void render(Canvas canvas) {
    if (hideable && gameRef.hideHints) return;
    super.render(canvas);
  }
}
