import 'dart:math';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// CPU controlled enemy. This component doesn't swipe on ice
class WalkerCpuComponent extends DynamicComponent {
  WalkerCpuComponent(tile) : super.fromTile(tile);

  @override
  int teamId = -3;

  @override
  void update(double dt) {
    if (randomDouble() > 0.2 && game.isNotPaused) {
      updateDirection(Direction.values[Random().nextInt(4)]);
      if (randomDouble() > 0.2) stop();
      super.update(dt);
    }
  }
}
