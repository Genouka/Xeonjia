import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// [AnimatedOpacity] widget shown while executing `(delete)`
class BlackCurtain extends StatefulWidget {
  const BlackCurtain(this.game, [this.callback]);
  final XeonjiaGame game;
  final VoidCallback? callback;

  @override
  State<BlackCurtain> createState() => _BlackCurtainState();
}

class _BlackCurtainState extends State<BlackCurtain> {
  bool visible = false;

  @override
  void initState() {
    widget.game.pause(stopMusic: false, stopEngine: false);
    widget.game.add(
      TimerComponent(period: 0.2, onTick: () => setState(() => visible = true)),
    );
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
          widget.game.overlays.remove('blackCurtain');
          widget.game.continueAction();
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
