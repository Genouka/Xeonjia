import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends DynamicComponent {
  int team = -2;
  SlitherCpuComponent(tile) : super.fromTile(tile);

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
