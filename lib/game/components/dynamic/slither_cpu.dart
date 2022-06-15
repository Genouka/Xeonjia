import 'dart:ui';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends DynamicComponent with LifePointsBar {
  SlitherCpuComponent(tile)
      : _updatePeriod = double.parse(tile.properties['updatePeriod'] ?? '0.8'),
        super.fromTile(tile) {
    _timeToNextMove = _updatePeriod;
  }

  @override
  int teamId = -2;

  // Frequency of movements (CPU only)
  final double _updatePeriod;
  double _timeToNextMove;

  @override
  void lifePointsDifference(double difference, {cause, double poison = 0}) {
    if (cause.isPlayerOne) {
      super.lifePointsDifference(difference, cause: cause, poison: poison);
    }
  }

  @override
  void update(double dt) {
    if ((_timeToNextMove -= dt) < 0 && game.isNotPaused) {
      updateDirection(GetDirection.random);
      _timeToNextMove = _updatePeriod;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, characterOffset));
  }
}
