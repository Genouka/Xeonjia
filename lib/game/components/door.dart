import 'package:xeonjia/game/xeonjia.dart';

/// Component that permits to change room
class DoorComponent extends BasicComponent {
  DoorComponent(super.tile)
    : _roomId = tile.properties['roomId'] ?? '0',
      _offset = GetDirection.fromInt(
        int.parse(tile.properties['orientation'] ?? '0'),
      ).opposite,
      super.fromTile();

  @override
  Future<void>? onLoad() {
    super.onLoad();
    x += componentSize * _offset.dx;
    y += componentSize * _offset.dy;
    return null;
  }

  @override
  int get priority => 500;

  /// Next Room ID
  final String _roomId;

  /// Door offset
  final Direction _offset;

  @override
  bool isSolid({BasicComponent? otherComponent}) =>
      !otherComponent!.isPlayerOne ||
      (game.inBattle &&
          (!game.map.canEscape ||
              !mainCharacter.visitedRooms.contains(_roomId)));

  @override
  void collidedBy(otherComponent, [bool wasStationary = false]) {
    if (otherComponent.isPlayerOne) {
      var count = game.enemies;
      game.setMessage(
        Message(
          game,
          count == 1
              ? "There is still 1 enemy here. I can't escape.".i18n
              : ("There are still %s enemies here. I can't escape.".i18n.fill([
                  count,
                ])),
        ),
      );
      otherComponent.updateOrientation(otherComponent.orientation.opposite);
    }
    super.collidedBy(otherComponent);
  }

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove.isPlayerOne) game.changeRoom(_roomId);
  }
}
