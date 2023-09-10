import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// A single game button (used for A, P, S, M, +, -, ...)
class Button extends HudButtonComponent {
  Button(
    this.text,
    this.onTap, {
    this.buttonPosition = Anchor.bottomRight,
    this.percent,
    this.color = Colors.blueGrey,
    this.visibility,
  })  : paint = Paint()
          ..strokeWidth = 6
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
    hasIcon = text.length > 1;
    if (!hasIcon) textBox.text = text;
  }

  Button.A(XeonjiaGame gameRef)
      : this(gameRef.inspectButtonKey, () => gameRef.user!.inspect(),
            visibility: () =>
                !gameRef.miniMapActive && (gameRef.user?.isMyTurn ?? false));

  Button.P(XeonjiaGame gameRef)
      : this(
          gameRef.punchButtonKey,
          () => gameRef.user!.shoot(0),
          buttonPosition: Anchor.topLeft,
          color: Colors.blue.shade800,
          visibility: () =>
              gameRef.overlays.isActive('rulesButton') &&
              gameRef.user!.isMyTurn,
        );

  Button.S(XeonjiaGame gameRef)
      : this(
          'snowball-icon',
          () => gameRef.user!.shoot(Weapons.snowball.id),
          buttonPosition: Anchor.topRight,
          color: Colors.blueGrey.shade800,
          percent: () =>
              gameRef.user!.getWeaponById(Weapons.snowball.id).ppPercentage,
          visibility: () =>
              gameRef.overlays.isActive('rulesButton') &&
              gameRef.user!.isMyTurn,
        );

  Button.M(XeonjiaGame gameRef)
      : this(
          'mine-icon',
          () => gameRef.user!.shoot(Weapons.mine.id),
          buttonPosition: Anchor.bottomLeft,
          color: Colors.blueGrey.shade800,
          percent: () =>
              gameRef.user!.getWeaponById(Weapons.mine.id).ppPercentage,
          visibility: () =>
              gameRef.overlays.isActive('rulesButton') &&
              gameRef.user!.isMyTurn,
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

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (hasIcon) {
      var atlas = await gameRef.loadCustomAtlas('images/metadata/weapons.xfa');
      spriteComponent =
          SpriteComponent(sprite: atlas.getSprite(text), priority: 9999999);
      placeSprite();
    }
  }

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

  SpriteComponent? spriteComponent;
  final TextBoxComponent textBox = TextBoxComponent(
      text: '', size: Vector2.all(40), align: Anchor.center, priority: 9999999);
  bool hasIcon = false;
  void placeSprite() {
    spriteComponent!.size = size / 1.3;
    spriteComponent!.x = (size.x - spriteComponent!.size.x) / 2;
    spriteComponent!.y = (size.y - spriteComponent!.size.y) / 2;
  }

  @override
  void onMount() {
    this.add(hasIcon ? spriteComponent! : textBox);
    super.onMount();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = Vector2.all(max(40, gameSize.toSize().shortestSide / 14));
    (button as CircleComponent).radius = size.x / 2;
    (buttonDown as CircleComponent).radius = size.x / 2;
    if (gameRef.buildContext != null) {
      if (spriteComponent != null) {
        placeSprite();
      } else {
        textBox.size = size;
        textBox.textRenderer = TextPaint(
            style: Theme.of(gameRef.buildContext!)
                .textTheme
                .labelLarge!
                .copyWith(fontSize: size.x / 1.5));
        textBox.text = text + ' ';
        textBox.text = text.trim();
      }
    }
    position = Vector2(gameSize.x - size.x * (buttonPosition.x == 0 ? 4 : 2),
        gameSize.y - size.x * (buttonPosition.y == 0 ? 4 : 2));
  }

  @override
  void render(Canvas canvas) {
    if (percent != null) {
      canvas.drawArc(
        Rect.fromCircle(
            radius: size.x / 2 + 3, center: Offset(size.x / 2, size.y / 2)),
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

/// Virtual D-pad
class VirtualDPad extends StatefulWidget {
  VirtualDPad(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  State<VirtualDPad> createState() => _VirtualDPadState();
}

class _VirtualDPadState extends State<VirtualDPad> {
  final Color arrowColor = Colors.white.withOpacity(0.7);
  final Color buttonColor = Colors.grey.withOpacity(0.3);
  Direction? direction;
  double size = 0;
  bool moving = false;

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
    return Icon(icon, color: arrowColor, size: size);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.shortestSide / 10 * settings.dPadSize;
    settings.dPadOffset = Offset(
        max(
            0,
            min(MediaQuery.of(context).size.width - size * 3,
                settings.dPadOffset.dx)),
        max(
            0,
            min(MediaQuery.of(context).size.height - size * 3,
                settings.dPadOffset.dy)));
    String currentMapId = widget.gameRef.map.id;
    return settings.showDPad
        ? Positioned(
            left: settings.dPadOffset.dx,
            bottom: settings.dPadOffset.dy,
            child: GestureDetector(
              onPanStart: (details) async {
                direction = getDirection(details.localPosition);
                if (direction == null) {
                  moving = true;
                } else {
                  while (direction != null &&
                      widget.gameRef.map.id == currentMapId &&
                      widget.gameRef.isNotPaused &&
                      !moving) {
                    widget.gameRef.movePlayer(direction!, slow: true);
                    await Future.delayed(const Duration(milliseconds: 50));
                  }
                }
              },
              onPanUpdate: (details) {
                if (moving) {
                  setState(() => settings.dPadOffset = Offset(
                      details.globalPosition.dx - size * 1.5,
                      MediaQuery.of(context).size.height -
                          details.globalPosition.dy -
                          size * 1.5));
                } else {
                  direction = getDirection(details.localPosition) ?? direction;
                }
              },
              onPanCancel: onLongPressEnd,
              onPanEnd: (_) => onLongPressEnd(),
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

  void onLongPressEnd() {
    direction = null;
    if (moving) saveSettings();
    moving = false;
  }

  Widget arrowButton(Direction? direction) {
    return direction != null
        ? Container(
            width: size,
            height: size,
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
        : Container(width: size, height: size, color: buttonColor);
  }

  Direction? getDirection(Offset position) {
    if (position.dx < size) {
      return Direction.left;
    } else if (position.dx > 2 * size) {
      return Direction.right;
    } else if (position.dy < size) {
      return Direction.up;
    } else if (position.dy > 2 * size) {
      return Direction.down;
    }
    return null;
  }

  Widget separator() => SizedBox(width: size, height: size);
}
