import 'package:xeonjia/game/xeonjia.dart';

/// Basic CPU controlled enemy that slides on ice
class SliderCpuComponent extends BasicComponent
    with Walker, RenderOffset, HPBar {
  SliderCpuComponent(tile) : super.fromTile(tile) {
    updateOrientation(
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0')));
    atlasAsset = 'monsters.xfa';
    weaponList = [PunchWeapon(level: level)];
    friendly = false;
    quiet = false;
    this.add(NpcController());
  }

  @override
  int teamId = -2;

  @override
  String? name = 'green';

  @override
  double get speed => Walker.defaultSpeed * 1.5;

  @override
  void hpDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if (cause?.isPlayerOne ?? false) {
      super.hpDifference(difference, cause: cause!, poison: poison);
    }
  }

  @override
  void delete({bool silently = false}) {
    isBeingDeleted = true;
    animation = atlas.getAnimation('$name-deletion')
      ..onComplete = () {
        hide();
        super.delete();
      };
  }
}
