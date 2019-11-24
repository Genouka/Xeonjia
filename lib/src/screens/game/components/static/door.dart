import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/character.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Component that permits to change room
class DoorComponent extends BasicComponent {
  // Next Room ID
  int _roomId;

  // True if a key is required to open this door
  bool _keyRequired;

  DoorComponent(tile)
      : _roomId = int.parse(tile.properties['roomId'] ?? '0'),
        _keyRequired = 'true' == (tile.properties['keyRequired'] ?? 'false'),
        super.fromTile(tile);

  @override
  bool isSolid({BasicComponent otherComponent}) =>
      _keyRequired == true && !player.doorKeyList.contains(_roomId) ||
      otherComponent is! CharacterComponent;

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove == player) {
      game.changeRoom(_roomId);
    }
  }
}
