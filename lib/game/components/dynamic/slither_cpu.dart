import 'package:xeonjia/game/components/abstract_dynamic.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends DynamicComponent {
  SlitherCpuComponent(tile) : super.fromTile(tile);

  @override
  int teamId = -2;

  @override
  void update(double t) {
    if (randomDouble() > 0.4) {
      if (randomDouble() > 0) {
        updateDirection(randomDouble(), 0);
      } else {
        updateDirection(0, randomDouble());
      }
    }
    super.update(t);
  }
}
