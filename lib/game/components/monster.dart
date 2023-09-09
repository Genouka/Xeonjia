import 'package:xeonjia/game/xeonjia.dart';

/// CPU controlled enemy that slides on ice (green/blue/red worms)
class MonsterComponent extends BasicComponent with Walker, RenderOffset, HPBar {
  MonsterComponent(tile) : super.fromTile(tile) {
    updateOrientation(
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0')));
    atlasAsset = 'monsters.xfa';
    weaponList = [PunchWeapon(level: level)];
    friendly = false;
    quiet = tile.properties['quiet'] == 'true';
    name = tile.properties['name'] ?? 'green';
    teamId = int.parse(tile.properties['team'] ?? '-2');
    this.add(NpcController());
  }

  @override
  double get speed => Walker.defaultSpeed * 1.5;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    if (tile.properties['visible'] == 'false') hide();
    if (!deleted && !isBeingDeleted) {
      reflection = IceReflection(this);
      gameRef.add(reflection!);
    }
  }

  @override
  void hpDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if (cause?.isUser ?? false) {
      super.hpDifference(difference, cause: cause!, poison: poison);
    }
  }

  @override
  void delete({bool silently = false}) {
    isBeingDeleted = true;
    if (this == gameRef.activePlayer && !gameRef.changingTurn) {
      gameRef.useMove(this, skipTurn: true);
    }
    if (silently) {
      super.delete();
    } else {
      animation = atlas.getAnimation('$name-deletion')
        ..onComplete = () {
          hide();
          super.delete();
        };
    }
  }
}
