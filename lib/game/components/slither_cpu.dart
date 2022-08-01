import 'dart:ui';

import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/utils/lifepoints_bar.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/weapons.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends BasicComponent with Walker, LifePointsBar {
  SlitherCpuComponent(tile)
      : _updatePeriod = double.parse(tile.properties['updatePeriod'] ?? '0.5'),
        super.fromTile(tile) {
    _timeToNextMove = _updatePeriod;
    weaponList = [PunchWeapon(level: level)];
  }

  @override
  int teamId = -2;

  @override
  String? atlasAsset = 'monsters.xfa';

  @override
  String? name = 'green';

  // Frequency of movements (CPU only)
  final double _updatePeriod;
  late double _timeToNextMove;

  @override
  void lifePointsDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if (cause?.isPlayerOne ?? false) {
      super.lifePointsDifference(difference, cause: cause!, poison: poison);
    }
  }

  @override
  void update(double dt) {
    if ((_timeToNextMove -= dt) < 0 && gameRef.isNotPaused) {
      updateDirection(GetDirection.random);
      _timeToNextMove = _updatePeriod;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, gameRef.characterOffset));
  }
}
