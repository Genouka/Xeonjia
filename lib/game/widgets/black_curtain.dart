import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// AnimatedOpacity widget shown while executing (delete)
class BlackCurtain extends StatefulWidget {
  const BlackCurtain(this.gameRef, [this.callback]);
  final XeonjiaGame gameRef;
  final VoidCallback? callback;

  @override
  State<BlackCurtain> createState() => _BlackCurtainState();
}

class _BlackCurtainState extends State<BlackCurtain> {
  bool visible = false;

  @override
  void initState() {
    widget.gameRef.pause(stopMusic: false, stopEngine: false);
    widget.gameRef.add(TimerComponent(
      period: 0.2,
      onTick: () => setState(() => visible = true),
    ));
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
            visible = !visible;
          });
        } else {
          widget.gameRef.overlays.remove('blackCurtain');
          widget.gameRef.continueAction();
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
