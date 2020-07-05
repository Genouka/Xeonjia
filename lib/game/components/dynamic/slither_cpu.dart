import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/models/direction.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends DynamicComponent {
  SlitherCpuComponent(tile) : super.fromTile(tile);

  @override
  int teamId = -2;

  @override
  void update(double t) {
    if (randomDouble() > 0.4) updateDirection(GetDirection.random);
    super.update(t);
  }
}
