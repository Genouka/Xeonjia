import 'dart:ui';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends DynamicComponent with LifePointsBar {
  SlitherCpuComponent(tile) : super.fromTile(tile) {
    level = atk ~/ 3;
  }

  @override
  int teamId = -2;

  @override
  void lifePointsDifference(double difference, {cause, double poison = 0}) {
    if (cause.isPlayerOne) {
      super.lifePointsDifference(difference, cause: cause, poison: poison);
    }
  }

  @override
  void update(double t) {
    if (randomDouble() > 0.4) updateDirection(GetDirection.random);
    super.update(t);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, -componentSize / 8));
  }
}
