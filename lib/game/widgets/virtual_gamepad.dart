import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// A single game button (used for A, P, S, +, -, ...)
class Button extends HudButtonComponent {
  Button(
    this.text,
    this.onTap, {
    this.buttonPosition = Anchor.bottomRight,
    this.percent,
    this.color = Colors.blueGrey,
    this.visibility,
  })  : paint = Paint()
          ..strokeWidth = 10
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.stroke,
        super(
          onReleased: () {
            if (visibility?.call() ?? true) onTap();
          },
          priority: 9999999,
        ) {
    (button as CircleComponent).paint.color = color.withOpacity(0.6);
    (buttonDown as CircleComponent).paint.color = color.withOpacity(0.4);
    textBox
      ..text = text
      ..priority = 9999999;
  }

  Button.A(XeonjiaGame gameRef)
      : this('A', gameRef.playerOne!.inspect,
            visibility: () =>
                !gameRef.miniMapActive && gameRef.playerOne!.isMyTurn);

  Button.P(XeonjiaGame gameRef)
      : this(
          'P',
          () => gameRef.playerOne!.shoot(0),
          buttonPosition: Anchor.topLeft,
          color: Colors.blue.shade800,
          visibility: () =>
              gameRef.overlays.isActive('rulesButton') &&
              gameRef.playerOne!.isMyTurn,
        );

  Button.S(XeonjiaGame gameRef)
      : this(
          'S',
          () => gameRef.playerOne!.shoot(1),
          buttonPosition: Anchor.topRight,
          color: Colors.blueGrey.shade800,
          percent: () => gameRef.playerOne!.getWeaponById(1).ppPercentage,
          visibility: () =>
              gameRef.overlays.isActive('rulesButton') &&
              gameRef.playerOne!.isMyTurn,
        );

  Button.plus(XeonjiaGame gameRef)
      : this(
          '+',
          gameRef.zoomMiniMap,
          buttonPosition: Anchor.topRight,
          color: Colors.grey.shade800.withOpacity(0.7),
          visibility: () => gameRef.miniMapActive,
        );

  Button.minus(XeonjiaGame gameRef)
      : this(
          '-',
          () => gameRef.zoomMiniMap(out: true),
          buttonPosition: Anchor.bottomRight,
          color: Colors.grey.shade800.withOpacity(0.7),
          visibility: () => gameRef.miniMapActive,
        );

  final String text;
  final VoidCallback onTap;
  final Color color;
  final Paint paint;
  final Anchor buttonPosition;
  final Function? percent;
  final Function? visibility;

  @override
  final PositionComponent button = CircleComponent(radius: 20, paint: Paint());

  @override
  final PositionComponent buttonDown =
      CircleComponent(radius: 20, paint: Paint());

  final TextBoxComponent textBox =
      TextBoxComponent(text: '', size: Vector2.all(40), align: Anchor.center);

  @override
  void onMount() {
    add(textBox);
    super.onMount();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = NotifyingVector2.all(max(40, gameSize.toSize().shortestSide / 14));
    (button as CircleComponent).radius = size.x / 2;
    (buttonDown as CircleComponent).radius = size.x / 2;
    textBox.size = size;
    if (gameRef.buildContext != null) {
      textBox.textRenderer = TextPaint(
          style: Theme.of(gameRef.buildContext!)
              .textTheme
              .button!
              .copyWith(fontSize: size.x / 1.5));
    }
    textBox.text = text + ' ';
    textBox.text = text.trim();
    position = Vector2(gameSize.x - size.x * (buttonPosition.x == 0 ? 4 : 2),
        gameSize.y - size.x * (buttonPosition.y == 0 ? 4 : 2));
  }

  @override
  void render(Canvas canvas) {
    if (percent != null) {
      canvas.drawArc(
        Rect.fromCircle(
            radius: size.x / 2, center: Offset(size.x / 2, size.y / 2)),
        -pi / 2,
        2 * pi * percent!(),
        false,
        paint,
      );
    }
    super.render(canvas);
  }

  @override
  void renderTree(Canvas canvas) {
    if (visibility?.call() ?? true) super.renderTree(canvas);
  }
}

/// Virtual Gamepad
class VirtualGamePad extends StatelessWidget {
  VirtualGamePad(this.gameRef);
  final XeonjiaGame gameRef;
  final Color arrowColor = Colors.white.withOpacity(0.7);
  final Color buttonColor = Colors.grey.withOpacity(0.3);
  static double _size = 0;

  Icon arrowIcon(Direction direction) {
    IconData icon;
    switch (direction) {
      case Direction.down:
        icon = Icons.keyboard_arrow_down_rounded;
        break;
      case Direction.up:
        icon = Icons.keyboard_arrow_up_rounded;
        break;
      case Direction.right:
        icon = Icons.keyboard_arrow_right_rounded;
        break;
      case Direction.left:
        icon = Icons.keyboard_arrow_left_rounded;
        break;
    }
    return Icon(icon, color: arrowColor, size: _size);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size.shortestSide / 10;
    String currentMapId = gameRef.map.id;
    return settings.showDPad
        ? Positioned(
            left: 30,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                Direction? direction = getDirection(details.localPosition);
                if (direction != null && gameRef.playerOne != null) {
                  gameRef.playerOne!.isStationary
                      ? gameRef.movePlayer(direction)
                      : gameRef.playerOne!.updateOrientation(direction);
                }
              },
              onLongPressStart: (LongPressStartDetails details) async {
                longPressingDirection = getDirection(details.localPosition);
                while (longPressingDirection != null &&
                    gameRef.map.id == currentMapId &&
                    gameRef.isNotPaused) {
                  gameRef.movePlayer(longPressingDirection!, slow: true);
                  await Future.delayed(const Duration(milliseconds: 50));
                }
              },
              onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                longPressingDirection = getDirection(details.localPosition) ??
                    longPressingDirection;
              },
              onLongPressEnd: (_) => longPressingDirection = null,
              onLongPressCancel: () => longPressingDirection = null,
              child: Column(
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
          )
        : Container();
  }

  Widget arrowButton(Direction? direction) {
    return direction != null
        ? Container(
            width: VirtualGamePad._size,
            height: VirtualGamePad._size,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.only(
                topLeft:
                    direction == Direction.up || direction == Direction.left
                        ? const Radius.circular(5)
                        : Radius.zero,
                topRight:
                    direction == Direction.up || direction == Direction.right
                        ? const Radius.circular(5)
                        : Radius.zero,
                bottomLeft:
                    direction == Direction.down || direction == Direction.left
                        ? const Radius.circular(5)
                        : Radius.zero,
                bottomRight:
                    direction == Direction.down || direction == Direction.right
                        ? const Radius.circular(5)
                        : Radius.zero,
              ),
            ),
            child: arrowIcon(direction),
          )
        : Container(
            width: VirtualGamePad._size,
            height: VirtualGamePad._size,
            color: buttonColor,
          );
  }

  Direction? getDirection(Offset position) {
    if (position.dx < _size) {
      return Direction.left;
    } else if (position.dx > 2 * _size) {
      return Direction.right;
    } else if (position.dy < _size) {
      return Direction.up;
    } else if (position.dy > 2 * _size) {
      return Direction.down;
    }
    return null;
  }

  Widget separator() =>
      SizedBox(width: VirtualGamePad._size, height: VirtualGamePad._size);
}

Direction? longPressingDirection;
