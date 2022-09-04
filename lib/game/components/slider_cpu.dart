import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/utils/hp_bar.dart';
import 'package:xeonjia/game/components/utils/npc_controller.dart';
import 'package:xeonjia/game/components/utils/render_offset.dart';
import 'package:xeonjia/game/utils/weapons.dart';

// Basic CPU controlled enemy that slides on ice
class SliderCpuComponent extends BasicComponent
    with Walker, RenderOffset, HPBar {
  SliderCpuComponent(tile) : super.fromTile(tile) {
    weaponList = [PunchWeapon(level: level)];
    friendly = false;
    quiet = false;
    add(NpcController());
  }

  @override
  int teamId = -2;

  @override
  String? atlasAsset = 'monsters.xfa';

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
