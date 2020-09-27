import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/models/direction.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends DynamicComponent with LifePointsBar {
  @override
  double initialLifePoints;
  SlitherCpuComponent(tile)
      : initialLifePoints =
            double.parse(tile.properties['lifePoints'] ?? 'Infinity'),
        super(tile.position, tile.properties['image'],
            imageY: tile.properties['imageY'] ?? 0) {
    // TODO: this + basic component + dynamic
    atk = double.parse(tile.properties['atk'] ?? '0');
    def = double.parse(tile.properties['def'] ?? '0');
    level = atk ~/ 3;
    actionOnEvent = tile.properties['actionOnEvent'] ?? '';
    action = tile.properties['action'] ?? '';
    executeAction();
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
}
