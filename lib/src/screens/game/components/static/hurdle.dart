import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';

// Hurdle component that can be bypassed only coming from the right direction
class HurdleComponent extends BasicComponent {
  // Other components direction that permits to jump over this component
  int _jumpDirection;

  HurdleComponent(tile)
      : _jumpDirection = int.parse(tile.properties['jumpDirection'] ?? '0'),
        super.fromTile(tile);

  @override
  bool isSolid({DynamicComponent otherComponent}) =>
      !((_jumpDirection == 1 && otherComponent.directionY > 0) ||
          (_jumpDirection == 2 && otherComponent.directionY < 0) ||
          (_jumpDirection == 3 && otherComponent.directionX > 0) ||
          (_jumpDirection == 4 && otherComponent.directionX < 0));
}
