import 'dart:ui';

import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/utils/direction.dart';

// Thin wall with one solid side
class ThinWallComponent extends BasicComponent {
  ThinWallComponent(tile)
      : _solidSide = GetDirection.fromInt(
            int.parse(tile.properties['solidSide'] ?? '0')),
        super.fromTile(tile);
  final Direction _solidSide;

  bool isBlocking(Direction direction) =>
      (_solidSide.dx != 0 && _solidSide.dx.sign == direction.dx.sign) ||
      (_solidSide.dy != 0 && _solidSide.dy.sign == direction.dy.sign);

  @override
  Rect? collisionRect(Walker otherComponent) {
    switch (_solidSide) {
      case Direction.down:
        return otherComponent.direction!.dy != 0
            ? Rect.fromLTWH(
                x,
                y + height + (otherComponent.direction!.dy > 0 ? 0 : -1),
                width,
                1)
            : null;
      case Direction.up:
        return otherComponent.direction!.dy != 0
            ? Rect.fromLTWH(
                x, y + (otherComponent.direction!.dy > 0 ? 0 : -1), width, 1)
            : null;
      case Direction.right:
        return otherComponent.direction!.dx != 0
            ? Rect.fromLTWH(
                x + width + (otherComponent.direction!.dx > 0 ? 0 : -1),
                y,
                1,
                height)
            : null;
      case Direction.left:
        return otherComponent.direction!.dx != 0
            ? Rect.fromLTWH(
                x + (otherComponent.direction!.dx > 0 ? 0 : -1), y, 1, height)
            : null;
      default:
        return null;
    }
  }
}
