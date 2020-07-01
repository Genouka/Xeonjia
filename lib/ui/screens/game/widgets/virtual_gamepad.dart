import 'package:flutter/material.dart';

import 'package:xeonjia/resources/global_variables.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/util/local_data_controller.dart';

enum Direction { right, left, up, down, center }

// Virtual gamepad used to move the player
class VirtualGamepad extends StatefulWidget {
  final bool manageMovements;
  VirtualGamepad({@required this.manageMovements});

  @override
  _VirtualGamepadState createState() => _VirtualGamepadState();
}

// Virtual gamepad widget
class _VirtualGamepadState extends State<VirtualGamepad> {
  // Gamepad position
  Offset _offset = kGamepadOffset;

  // Arrow button color
  final Color _buttonColor = Colors.blueGrey[500];

  // Map direction-button icon
  final Map<Direction, dynamic> arrowIconMap = {
    Direction.up: const Icon(Icons.keyboard_arrow_up),
    Direction.down: const Icon(Icons.keyboard_arrow_down),
    Direction.left: const Icon(Icons.keyboard_arrow_left),
    Direction.right: const Icon(Icons.keyboard_arrow_right),
    Direction.center: const Icon(Icons.add),
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: _offset.dx,
        bottom: _offset.dy,
        child: Column(
          children: [
            Row(
              children: [
                separator(),
                arrowButton(Direction.up),
                separator(),
              ],
            ),
            Row(
              children: [
                arrowButton(Direction.left),
                arrowButton(Direction.center),
                arrowButton(Direction.right),
              ],
            ),
            Row(
              children: [
                separator(),
                arrowButton(Direction.down),
                separator(),
              ],
            ),
          ],
        ));
  }

  // Gamepad button widget
  Widget arrowButton(Direction direction) {
    return widget.manageMovements
        ? GestureDetector(
            // Edit widget position by moving it
            onPanUpdate: (details) {
              setState(() {
                if (direction == Direction.center) {
                  var _dx = details.delta.dx;
                  var _dy = details.delta.dy;
                  if (_dx.abs() > _dy.abs()) {
                    _dy = 0;
                  } else {
                    _dx = 0;
                  }
                  playerOne.updateOrientation(_dx, _dy);
                } else {
                  _offset = Offset(_offset.dx - details.delta.dx,
                      _offset.dy - details.delta.dy);
                }
              });
            },
            child: _button(direction))
        : _button(direction);
  }

  Widget _button(Direction direction) => IconButton(
        icon: arrowIconMap[direction],
        iconSize: settings.gamepadSize,
        color: _buttonColor,
        onPressed: () {
          input(direction);
        },
      );

  // Empty space in gamepad
  Widget separator() =>
      Container(width: settings.gamepadSize, height: settings.gamepadSize);

  // Manage direction input
  void input(Direction direction) {
    if (direction == Direction.center) {
      playerOne.shoot();
    } else {
      if (widget.manageMovements) {
        game.gestureDragInput(directionToOffset(direction));
      } else {
        var _orientation = directionToOffset(direction);
        playerOne.updateOrientation(_orientation.dx, _orientation.dy);
      }
    }
    saveOffset(_offset);
  }

  // Save widget position to be used in next matches
  void saveOffset(Offset newOffset) {
    if (newOffset != kGamepadOffset) {
      kGamepadOffset = newOffset;
      saveGamepadOffset();
    }
  }

  // Convert offset into direction
  Offset directionToOffset(Direction direction) {
    switch (direction) {
      case Direction.right:
        return const Offset(1, 0);
      case Direction.left:
        return const Offset(-1, 0);
      case Direction.up:
        return const Offset(0, -1);
      case Direction.down:
        return const Offset(0, 1);
      default:
        return const Offset(0, 0);
    }
  }
}
