import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Floating virtual gamepad used to move the player
class FloatingGamepad extends StatefulWidget {
  @override
  _FloatingGamepadState createState() => _FloatingGamepadState();
}

// Map direction-buttonIcon
Map<String, dynamic> arrowIconMap = {
  'up': Icon(Icons.keyboard_arrow_up),
  'down': Icon(Icons.keyboard_arrow_down),
  'left': Icon(Icons.keyboard_arrow_left),
  'right': Icon(Icons.keyboard_arrow_right),
  'center': Icon(Icons.add),
};

// Floating gamepad widget
class _FloatingGamepadState extends State<FloatingGamepad> {
  Color _buttonColor = Colors.blueGrey[500];
  Offset _offset = kGamepadOffset;
  Widget build(BuildContext context) {
    return Positioned(
        right: _offset.dx,
        bottom: _offset.dy,
        child: Column(
          children: [
            Row(
              children: [
                _separator(),
                _arrowButton('up'),
                _separator(),
              ],
            ),
            Row(
              children: [
                _arrowButton('left'),
                if (settings.gamepadShape == 0)
                  _arrowButton('center')
                else
                  _arrowButton('down'),
                _arrowButton('right'),
              ],
            ),
            if (settings.gamepadShape == 0)
              Row(
                children: [
                  _separator(),
                  _arrowButton('down'),
                  _separator(),
                ],
              ),
          ],
        ));
  }

  // Gamepad button widget
  Widget _arrowButton(String direction) {
    // Manage onTapDown (isTapDown=false) and onTapUp events (isTapDown=true)
    void _buttonInput({@required bool isTapDown}) {
      switch (direction) {
        case 'up':
          isTapDown ? player.updateOrientation(0, -1) : _upInput();
          break;
        case 'down':
          isTapDown ? player.updateOrientation(0, 1) : _downInput();
          break;
        case 'left':
          isTapDown ? player.updateOrientation(-1, 0) : _leftInput();
          break;
        case 'right':
          isTapDown ? player.updateOrientation(1, 0) : _rightInput();
          break;
        case 'center':
          if (!isTapDown) player.selectedWeapon.shoot(shooter: player);
          break;
        default:
          break;
      }
    }

    return Card(
        color: Colors.white.withOpacity(0),
        elevation: 0,
        child: GestureDetector(
            onTapDown: (details) {
              _buttonInput(isTapDown: true);
            },
            child: IconButton(
              icon: arrowIconMap[direction],
              iconSize: settings.gamepadSize,
              color: _buttonColor,
              onPressed: () {
                _buttonInput(isTapDown: false);
              },
            )));
  }

  // White space in gamepad
  Widget _separator() =>
      Container(width: settings.gamepadSize, height: settings.gamepadSize);

  // Manage up direction input
  void _upInput() {
    game.gestureDragInput(Offset(0, -1));
    _saveOffset(_offset);
  }

  // Manage down direction input
  void _downInput() {
    game.gestureDragInput(Offset(0, 1));
    _saveOffset(_offset);
  }

  // Manage left direction input
  void _leftInput() {
    game.gestureDragInput(Offset(-1, 0));
    _saveOffset(_offset);
  }

  // Manage right direction input
  void _rightInput() {
    game.gestureDragInput(Offset(1, 0));
    _saveOffset(_offset);
  }

  // Save widget position to be used in next matches
  // Currently disabled
  void _saveOffset(Offset newOffset) {
    /*
    if (newOffset != kGamepadOffset) {
      kGamepadOffset = newOffset;
      //saveGamepadOffset();
    }
    */
  }
}
