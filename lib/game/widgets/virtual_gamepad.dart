import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// A single game button (used for A, P, S, +, -, ...)
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
    (button as CircleComponent).paint.color = color;
    (buttonDown as CircleComponent).paint.color = color.withOpacity(0.9);
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

// Virtual Gamepad
class VirtualGamePad extends StatelessWidget {
  VirtualGamePad(this.gameRef);
  final XeonjiaGame gameRef;
  static double _size = 0;
  static const Color arrowColor = Colors.white;
  final Color buttonColor = Colors.grey.withOpacity(0.4);

  final Map<Direction, dynamic> arrowIconMap = {
    Direction.up:
        const Icon(Icons.keyboard_arrow_up, color: VirtualGamePad.arrowColor),
    Direction.down:
        const Icon(Icons.keyboard_arrow_down, color: VirtualGamePad.arrowColor),
    Direction.left:
        const Icon(Icons.keyboard_arrow_left, color: VirtualGamePad.arrowColor),
    Direction.right: const Icon(Icons.keyboard_arrow_right,
        color: VirtualGamePad.arrowColor),
  };

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size.shortestSide / 14;
    return settings.showDPad
        ? Positioned(
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
          )
        : Container();
  }

  Widget arrowButton(Direction? direction) {
    return GestureDetector(
      onTap: direction != null
          ? () {
              gameRef.playerOne!.isStationary
                  ? gameRef.movePlayer(direction)
                  : gameRef.playerOne!.updateOrientation(direction);
            }
          : null,
      onLongPress: direction != null
          ? () {
              gameRef.playerOne!.updateOrientation(direction);
            }
          : null,
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
}
