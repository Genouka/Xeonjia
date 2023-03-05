import 'package:xeonjia/game/xeonjia.dart';

/// Component that permits to change room
class DoorComponent extends BasicComponent {
  DoorComponent(tile)
      : _roomId = tile.properties['roomId'] ?? '0',
        _offset = GetDirection.fromInt(
                int.parse(tile.properties['orientation'] ?? '0'))
            .opposite,
        super.fromTile(tile);

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
      (gameRef.enemies != 0 && !gameRef.map.canEscape);

  @override
  void collidedBy(otherComponent, [bool wasStationary = false]) {
    if (otherComponent.isPlayerOne) {
      var count = gameRef.enemies;
      gameRef.setMessage(Message(
          gameRef,
          count == 1
              ? "There is still 1 enemy here. I can't escape.".i18n
              : ("There are still %s enemies here. I can't escape."
                  .i18n
                  .fill([count]))));
      otherComponent.updateOrientation(otherComponent.orientation.opposite);
    }
    super.collidedBy(otherComponent);
  }

  @override
  void overlappedBy(BasicComponent componentAbove) {
    if (componentAbove.isPlayerOne) gameRef.changeRoom(_roomId);
  }
}
