import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Ground component
// Other components walk on this instead of sliding
class GroundComponent extends BasicComponent {
  // True if this is not on the ground floor
  final bool flying;

  GroundComponent(tile)
      : flying = 'true' == (tile.properties['flying'] ?? 'false'),
        super.fromTile(tile);

  @override
  bool isSolid({BasicComponent otherComponent}) => false;

  @override
  void overlappedBy(DynamicComponent componentAbove) {
    if (componentAbove.isFlying() != flying) return;
    var _thisRect = toRect();
    var _aboveRect = componentAbove.toRect();
    if (componentAbove.direction.dx != 0) {
      if (_thisRect.center.dx == _aboveRect.center.dx &&
          // Do not stop if the head of componentAbove is overlapping this
          _thisRect.bottomCenter.dy > _aboveRect.center.dy &&
          _thisRect.topCenter.dy <= _aboveRect.center.dy) {
        componentAbove.stop();
      }
    } else {
      if (_thisRect.center.dy == _aboveRect.center.dy &&
          _thisRect.centerLeft.dx <= _aboveRect.center.dx &&
          _thisRect.centerRight.dx >= _aboveRect.center.dx) {
        componentAbove.stop();
      }
    }
  }
}
