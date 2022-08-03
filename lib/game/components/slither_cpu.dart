import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/utils/lifepoints_bar.dart';
import 'package:xeonjia/game/components/utils/npc_controller.dart';
import 'package:xeonjia/game/components/utils/render_offset.dart';
import 'package:xeonjia/game/utils/weapons.dart';

// Basic CPU controlled enemy that slides on ice
class SlitherCpuComponent extends BasicComponent
    with Walker, RenderOffset, LifePointsBar {
  SlitherCpuComponent(tile) : super.fromTile(tile) {
    weaponList = [PunchWeapon(level: level)];
    add(NpcController());
  }

  @override
  int teamId = -2;

  @override
  String? atlasAsset = 'monsters.xfa';

  @override
  String? name = 'green';

  @override
  void lifePointsDifference(double difference,
      {BasicComponent? cause, double poison = 0}) {
    if (cause?.isPlayerOne ?? false) {
      super.lifePointsDifference(difference, cause: cause!, poison: poison);
    }
  }
}
