import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Component that can be bypassed only if coming from the allowed direction
class HurdleComponent extends BasicComponent {
  // Other components direction that permits to jump over this component
  final Direction _allowedDirection;

  HurdleComponent(tile)
      : _allowedDirection = GetDirection.fromInt(
            int.parse(tile.properties['allowedDirection'] ?? '0')),
        super.fromTile(tile);

  @override
  bool isSolid({DynamicComponent otherComponent}) =>
      otherComponent.direction != _allowedDirection;
}
