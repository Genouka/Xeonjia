import 'package:flutter/material.dart';

import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';

// Direction changer component
// Change the direction of the components that walk over this
class DirectionChangerComponent extends BasicComponent {
  int _forcedDirection;

  DirectionChangerComponent(tile)
      : _forcedDirection = int.parse(tile.properties['forcedDirection'] ?? '0'),
        super.fromTile(tile);

  @override
  bool isSolid({BasicComponent otherComponent}) => false;

  @override
  void overlappedBy(DynamicComponent componentAbove) {
    if (componentAbove.isFlying()) return;
    List<double> _directionXY = directionToXY(_forcedDirection);
    Rect _thisRect = toRect();
    Rect _aboveRect = componentAbove.toRect();
    if (_thisRect.center == _aboveRect.center) {
      componentAbove.updateDirection(_directionXY.first, _directionXY.last,
          forced: true);
    }
  }
}
