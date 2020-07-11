import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';

// Virtual stick + buttons
class VirtualGamePad extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(children: [Stick(), Buttons()]);
}

// Buttons on the right
class Buttons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: 120,
      width: 120,
      bottom: 15,
      right: 15,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              button('A', () {
                playerOne.inspect();
              }),
              button('S', () {
                playerOne.shoot(
                    playerOne.weaponList.whereType<SnowBallWeapon>().single);
              }),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              button('M', () {
                playerOne
                    .shoot(playerOne.weaponList.whereType<MineWeapon>().single);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget button(String text, VoidCallback onTap) => InkWell(
        child: CircleAvatar(
            child: Text(text), backgroundColor: Colors.white54, radius: 24),
        onTap: onTap,
      );
}

// Virtual stick on the left
class Stick extends StatefulWidget {
  @override
  StickState createState() => StickState();
}

class StickState extends State<Stick> {
  final padSize = 45.0;
  final margin = const Offset(15, 15);
  Offset position = Offset.zero;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: 120,
      width: 120,
      bottom: margin.dy,
      left: margin.dx,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(60),
            ),
            child: GestureDetector(
              child: Center(
                child: Transform.translate(
                  offset: position,
                  child: SizedBox(
                    height: padSize,
                    width: padSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
              onPanDown: onPanDown,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              onPanCancel: onPanCancel,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: const Icon(Icons.keyboard_arrow_up,
                        color: Colors.black),
                    onTap: () {
                      updatePlayer(orientation: Direction.up);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: const Icon(Icons.keyboard_arrow_left,
                        color: Colors.black),
                    onTap: () {
                      updatePlayer(orientation: Direction.left);
                    },
                  ),
                  InkWell(
                    child: const Icon(Icons.keyboard_arrow_right,
                        color: Colors.black),
                    onTap: () {
                      updatePlayer(orientation: Direction.right);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.black),
                    onTap: () {
                      updatePlayer(orientation: Direction.down);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void setPosition(Offset newDelta) {
    setState(() {
      position = newDelta;
    });
  }

  void offsetToDelta(Offset offset) {
    var newDelta = offset - Offset(padSize, padSize) - margin;
    setPosition(
        Offset.fromDirection(newDelta.direction, min(60, newDelta.distance)));
  }

  void updatePlayer({Direction orientation}) {
    if (orientation != null) {
      playerOne.updateOrientation(orientation);
    } else if (position.distanceSquared > 900) {
      playerOne.isStationary
          ? playerOne.updateDirection(GetDirection.fromOffset(position))
          : playerOne.updateOrientation(GetDirection.fromOffset(position));
    }
  }

  void onPanDown(DragDownDetails details) {
    offsetToDelta(details.localPosition);
    updatePlayer();
    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      updatePlayer();
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    offsetToDelta(details.localPosition);
  }

  void onPanEnd(_) {
    setPosition(Offset.zero);
    timer?.cancel();
  }

  void onPanCancel() {
    setPosition(Offset.zero);
    timer?.cancel();
  }
}
