import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Component that permits to change room
class DoorComponent extends BasicComponent {
  // Next Room ID
  final String _roomId;

  // Door offset
  final Direction _offset;

  DoorComponent(tile)
      : _roomId = tile.properties['roomId'] ?? '0',
        _offset = GetDirection.fromInt(
                int.parse(tile.properties['orientation'] ?? '0'))
            .opposite,
        super.fromTile(tile) {
    x += componentSize * _offset.dx;
    y += componentSize * _offset.dy;
  }

  @override
  bool isSolid({BasicComponent otherComponent}) =>
      !otherComponent.isPlayerOne ||
      (game.components
              .where((element) =>
                  element is BasicComponent &&
                  [-3, -2, 1].contains(element.teamId))
              .isNotEmpty &&
          _roomId !=
              mainCharacter
                  .visitedRooms[mainCharacter.visitedRooms.length - 2]);

  @override
  void collidedBy(otherComponent) {
    if (otherComponent.isPlayerOne) {
      game.setMessage(
          Message("There are still monsters here. I can't escape.".i18n));
      otherComponent.updateOrientation(otherComponent.orientation.opposite);
    }
    super.collidedBy(otherComponent);
  }

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove.isPlayerOne) game.changeRoom(_roomId);
  }
}
