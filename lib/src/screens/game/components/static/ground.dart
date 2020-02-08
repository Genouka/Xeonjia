import 'package:flutter/material.dart';

import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';

// Ground component
// Other components walk on this instead of sliding
class GroundComponent extends BasicComponent {
  GroundComponent(tile) : super.fromTile(tile);

  @override
  bool isSolid({BasicComponent otherComponent}) => false;

  @override
  void overlappedBy(DynamicComponent componentAbove) {
    if (componentAbove.isFlying()) return;
    Rect _thisRect = toRect();
    Rect _aboveRect = componentAbove.toRect();
    if (componentAbove.directionX != 0) {
      if (_thisRect.center.dx == _aboveRect.center.dx &&
          _thisRect.bottomCenter.dy > _aboveRect.center.dy &&
          _thisRect.topCenter.dy < _aboveRect.center.dy) {
        componentAbove.stop();
      }
    } else {
      if (_thisRect.center.dy == _aboveRect.center.dy &&
          _thisRect.centerLeft.dx < _aboveRect.center.dx &&
          _thisRect.centerRight.dx > _aboveRect.center.dx) {
        componentAbove.stop();
      }
    }
  }
}
