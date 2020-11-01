import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/util/screen_dimension.dart';

// Gamepad size
double _size;

// Virtual Gamepad (D-pad + buttons)
class VirtualGamePad extends StatelessWidget {
  VirtualGamePad() {
    _size = min(screenSize.width, screenSize.height) / 14;
  }

  final buttons = _Buttons();

  @override
  Widget build(BuildContext context) =>
      Stack(children: [if (settings.showDPad) _DPad(), buttons]);

  void refresh() {
    buttons.state.refresh();
  }
}

// Virtual D-pad (on the left)
class _DPad extends StatelessWidget {
  final Color buttonColor = Colors.grey.withOpacity(0.4);
  static final Color arrowColor = Colors.white;

  // Map direction-button icon
  final Map<Direction, dynamic> arrowIconMap = {
    Direction.up: Icon(Icons.keyboard_arrow_up, color: arrowColor),
    Direction.down: Icon(Icons.keyboard_arrow_down, color: arrowColor),
    Direction.left: Icon(Icons.keyboard_arrow_left, color: arrowColor),
    Direction.right: Icon(Icons.keyboard_arrow_right, color: arrowColor),
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      bottom: 20,
      child: InkWell(
        onTap: () {},
        child: Container(
          width: _size * 4,
          height: _size * 4,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  separator(),
                  arrowButton(Direction.up),
                  separator(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  arrowButton(Direction.left),
                  arrowButton(null),
                  arrowButton(Direction.right),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  separator(),
                  arrowButton(Direction.down),
                  separator(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget arrowButton(Direction direction) {
    return GestureDetector(
      onTap: () {
        game.playerOne.isStationary
            ? game.playerOne.updateDirection(direction)
            : game.playerOne.updateOrientation(direction);
      },
      onLongPress: () {
        game.playerOne.updateOrientation(direction);
      },
      child: direction != null
          ? Container(
              width: _size,
              height: _size,
              color: buttonColor,
              child: arrowIconMap[direction],
            )
          : Container(width: _size, height: _size, color: buttonColor),
    );
  }

  Widget separator() => Container(width: _size, height: _size);
}

// Buttons (on the right)
class _Buttons extends StatefulWidget {
  final _ButtonsState state = _ButtonsState();

  @override
  _ButtonsState createState() => state;
}

class _ButtonsState extends State<_Buttons> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: _size * 4,
          height: _size * 4,
          color: Colors.transparent,
          child: Column(
            children: [
              Row(
                children: [
                  button('P', () => game.playerOne.shootById(0),
                      percentage: 1,
                      highlight: game.playerOne.selectedWeapon.id == 0),
                  game.playerOne.hasWeaponId(2)
                      ? button('M', () => game.playerOne.shootById(2),
                          percentage:
                              game.playerOne.getWeaponById(2).ppPercentage,
                          highlight: game.playerOne.selectedWeapon.id == 2)
                      : const Spacer(),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  game.playerOne.hasWeaponId(1)
                      ? button('S', () => game.playerOne.shootById(1),
                          percentage:
                              game.playerOne.getWeaponById(1).ppPercentage,
                          highlight: game.playerOne.selectedWeapon.id == 1)
                      : const Spacer(),
                  if (game.config.mode == GameMode.story)
                    button(
                      'A',
                      game.playerOne.inspect,
                      percentage: 0,
                      color: Colors.blueGrey[400],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Widget button(String text, VoidCallback onTap,
          {double percentage, bool highlight = false, Color color}) =>
      InkWell(
        child: Container(
          margin: EdgeInsets.all(_size / 5),
          child: Stack(
            children: [
              CustomPaint(
                child: Container(color: Colors.transparent),
                painter: _PiePainter(percentage ?? 1),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: _size / 1.7,
                  backgroundColor:
                      highlight ? Colors.blue[700] : (color ?? Colors.grey),
                  foregroundColor: Colors.white,
                  child: Text(
                    text,
                    style: TextStyle(fontSize: _size / 2 + 4),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      );
}

// Paint a pie chart
class _PiePainter extends CustomPainter {
  final double percentage;
  _PiePainter(this.percentage);

  Path path(double size, double fromRadius, double toRadius) => Path()
    ..moveTo(size, size)
    ..arcTo(Rect.fromCircle(radius: size, center: Offset(size, size)),
        fromRadius, toRadius, false)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        path(_size / 1.7 + 4, 1.5 * pi, 2 * pi * (percentage - 0.0001)),
        (Paint()..color = Colors.blue));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
