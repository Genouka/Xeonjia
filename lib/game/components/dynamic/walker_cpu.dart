import 'package:xeonjia/game/components/abstract_dynamic.dart';

// CPU controlled enemy. This component doesn't swipe on ice
class WalkerCpuComponent extends DynamicComponent {
  WalkerCpuComponent(tile) : super.fromTile(tile);

  @override
  int teamId = -3;

  @override
  void update(double t) {
    if (randomDouble() > 0.2) {
      randomDouble() > 0
          ? directionX = randomDouble()
          : directionY = randomDouble();
      if (randomDouble() > 0.2) stop();
      updateOrientation(directionX, directionY);
      super.update(t);
    }
  }
}
