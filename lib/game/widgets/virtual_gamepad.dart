import 'dart:math';

import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// Virtual Gamepad (D-pad + buttons)
class VirtualGamePad extends StatelessWidget {
  VirtualGamePad(this.gameRef);
  final XeonjiaGame gameRef;

  final GlobalKey<_ButtonsState> _buttonsKey = GlobalKey();
  final GlobalKey<_DPadState> _dPadKey = GlobalKey();
  static double _size = 0;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    _size = min(screenSize.width, screenSize.height) / 12;
    return Stack(children: [
      if (settings.showDPad) _DPad(gameRef, _dPadKey),
      _Buttons(gameRef, _buttonsKey),
    ]);
  }

  void refresh() {
    if (settings.showDPad) _dPadKey.currentState?.refresh();
    _buttonsKey.currentState?.refresh();
  }
}

// Virtual D-pad (on the left)
class _DPad extends StatefulWidget {
  const _DPad(this.gameRef, Key key) : super(key: key);
  final XeonjiaGame gameRef;
  static const Color arrowColor = Colors.white;

  @override
  _DPadState createState() => _DPadState();
}

class _DPadState extends State<_DPad> {
  final Color buttonColor = Colors.grey.withOpacity(0.4);

  final Map<Direction, dynamic> arrowIconMap = {
    Direction.up: const Icon(Icons.keyboard_arrow_up, color: _DPad.arrowColor),
    Direction.down:
        const Icon(Icons.keyboard_arrow_down, color: _DPad.arrowColor),
    Direction.left:
        const Icon(Icons.keyboard_arrow_left, color: _DPad.arrowColor),
    Direction.right:
        const Icon(Icons.keyboard_arrow_right, color: _DPad.arrowColor),
  };

  @override
  Widget build(BuildContext context) {
    if (widget.gameRef.miniMapEnabled) return Container();
    return Positioned(
      left: 20,
      bottom: 20,
      child: InkWell(
        onTap: () {},
        child: Container(
          width: VirtualGamePad._size * 4,
          height: VirtualGamePad._size * 4,
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

  Widget arrowButton(Direction? direction) {
    return GestureDetector(
      onTap: () {
        widget.gameRef.playerOne!.isStationary
            ? widget.gameRef.gestureDragInput(direction!)
            : widget.gameRef.playerOne!.updateOrientation(direction);
      },
      onLongPress: () {
        widget.gameRef.playerOne!.updateOrientation(direction);
      },
      child: direction != null
          ? Container(
              width: VirtualGamePad._size,
              height: VirtualGamePad._size,
              color: buttonColor,
              child: arrowIconMap[direction],
            )
          : Container(
              width: VirtualGamePad._size,
              height: VirtualGamePad._size,
              color: buttonColor),
    );
  }

  Widget separator() =>
      SizedBox(width: VirtualGamePad._size, height: VirtualGamePad._size);

  void refresh() {
    if (mounted) setState(() {});
  }
}

// Buttons (on the right)
class _Buttons extends StatefulWidget {
  const _Buttons(this.gameRef, Key key) : super(key: key);
  final XeonjiaGame gameRef;

  @override
  _ButtonsState createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons> {
  @override
  Widget build(BuildContext context) {
    return widget.gameRef.playerOne == null
        ? Container()
        : Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onPanUpdate: (upd) => widget.gameRef
                  .onPanUpdate(DragUpdateInfo.fromDetails(widget.gameRef, upd)),
              onPanEnd: (end) => widget.gameRef
                  .onPanEnd(DragEndInfo.fromDetails(widget.gameRef, end)),
              child: Container(
                width: VirtualGamePad._size * 4,
                height: VirtualGamePad._size * 4,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Row(
                      children: widget.gameRef.miniMapEnabled
                          ? [
                              const Spacer(),
                              button(
                                '+',
                                () => widget.gameRef.zoomMiniMap(),
                                percentage: 0,
                                highlight: false,
                                color: Colors.grey.shade800.withOpacity(0.7),
                              ),
                            ]
                          : [
                              button('P',
                                  () => widget.gameRef.playerOne!.shootById(0),
                                  percentage: 1,
                                  highlight: widget.gameRef.playerOne!
                                          .selectedWeapon.id ==
                                      0),
                              if (widget.gameRef.playerOne!.hasWeaponId(2))
                                button(
                                    'M',
                                    () =>
                                        widget.gameRef.playerOne!.shootById(2),
                                    percentage: widget.gameRef.playerOne!
                                        .getWeaponById(2)
                                        .ppPercentage,
                                    highlight: widget.gameRef.playerOne!
                                            .selectedWeapon.id ==
                                        2)
                              else
                                const Spacer(),
                            ],
                    ),
                    const Spacer(),
                    Row(
                      children: widget.gameRef.miniMapEnabled
                          ? [
                              const Spacer(),
                              button(
                                '-',
                                () => widget.gameRef.zoomMiniMap(out: true),
                                percentage: 0,
                                highlight: false,
                                color: Colors.grey.shade800.withOpacity(0.7),
                              ),
                            ]
                          : [
                              if (widget.gameRef.playerOne!.hasWeaponId(1))
                                button(
                                    'S',
                                    () =>
                                        widget.gameRef.playerOne!.shootById(1),
                                    percentage: widget.gameRef.playerOne!
                                        .getWeaponById(1)
                                        .ppPercentage,
                                    highlight: widget.gameRef.playerOne!
                                            .selectedWeapon.id ==
                                        1)
                              else
                                const Spacer(),
                              if (widget.gameRef.config.mode == GameMode.story)
                                button(
                                  'A',
                                  widget.gameRef.playerOne!.inspect,
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
          {double? percentage, bool highlight = false, Color? color}) =>
      InkWell(
        onTap: onTap,
        enableFeedback: false,
        child: Container(
          margin: EdgeInsets.all(VirtualGamePad._size / 5),
          child: Stack(
            children: [
              CustomPaint(
                painter: _PiePainter(percentage ?? 1),
                child: Container(color: Colors.transparent),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: VirtualGamePad._size / 1.7,
                  backgroundColor:
                      highlight ? Colors.blue[700] : (color ?? Colors.grey),
                  foregroundColor: Colors.white,
                  child: Text(
                    text,
                    style: TextStyle(fontSize: VirtualGamePad._size / 2 + 4),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// Paint a pie chart
class _PiePainter extends CustomPainter {
  _PiePainter(this.percentage);
  final double percentage;

  Path path(double size, double fromRadius, double toRadius) => Path()
    ..moveTo(size, size)
    ..arcTo(Rect.fromCircle(radius: size, center: Offset(size, size)),
        fromRadius, toRadius, false)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        path(VirtualGamePad._size / 1.7 + 4, 1.5 * pi,
            2 * pi * (percentage - 0.0001)),
        (Paint()..color = Colors.blue));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
