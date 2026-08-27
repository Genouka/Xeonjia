import 'dart:ui';

import 'package:xeonjia/game/xeonjia.dart';

/// Static component
class StaticComponent extends BasicComponent {
  StaticComponent(super.tile, {this._walkable = false})
    : isSlippery = (tile.properties['slippery'] ?? 'false') == 'true',
      hideable = (tile.properties['hideable'] ?? 'false') == 'true',
      super.fromTile();

  /// If true: other components slide on this
  bool isSlippery;

  /// If true: other components can walk on this
  final bool _walkable;
  bool get isFloor => _walkable;

  /// If true: this component can be hidden from UI buttons (used for hints)
  final bool hideable;

  @override
  Rect? collisionRect(Walker otherComponent) {
    if (isSlippery) return null;
    if (!_walkable) return super.collisionRect(otherComponent);
    if (otherComponent.isFlying() != isFlying() ||
        otherComponent.wasStationary) {
      return null;
    }
    return oppositeBorderRect(otherComponent);
  }

  @override
  void render(Canvas canvas) {
    if (hideable && game.hideHints) return;
    super.render(canvas);
  }
}
