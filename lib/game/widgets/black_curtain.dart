import 'package:flame/components/timer_component.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';

// AnimatedOpacity widget shown while executing (delete)
class BlackCurtain extends StatefulWidget {
  final VoidCallback callback;
  BlackCurtain([this.callback]);

  @override
  _BlackCurtainState createState() => _BlackCurtainState();
}

class _BlackCurtainState extends State<BlackCurtain> {
  bool visible = false;

  @override
  void initState() {
    game.pause(stopMusic: false, stopEngine: false);
    game.addLater(TimerComponent(Timer(
      0.2,
      callback: () {
        setState(() {
          visible = true;
        });
      },
      repeat: false,
    )..start()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      onEnd: () {
        if (visible) {
          setState(() {
            widget.callback?.call();
            return visible = !visible;
          });
        } else {
          game.removeWidgetOverlay('blackCurtain');
          game.continueAction();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
      ),
    );
  }
}
