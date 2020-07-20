import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Component that permits to change room
class DoorComponent extends BasicComponent {
  // Next Room ID
  final int _roomId;

  // True if a key is required to open this door
  final bool _keyRequired;

  // Door offset
  final Direction _offset;

  DoorComponent(tile)
      : _roomId = int.parse(tile.properties['roomId'] ?? '0'),
        _keyRequired = 'true' == (tile.properties['keyRequired'] ?? 'false'),
        _offset = GetDirection.fromInt(
                int.parse(tile.properties['orientation'] ?? '0'))
            .opposite,
        super.fromTile(tile) {
    x += componentSize * _offset.dx;
    y += componentSize * _offset.dy;
  }

  @override
  bool isSolid({BasicComponent otherComponent}) =>
      _keyRequired == true && !playerOne.doorKeyList.contains(_roomId) ||
      otherComponent is! CharacterComponent;

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove == playerOne) game.changeRoom(_roomId);
  }
}
