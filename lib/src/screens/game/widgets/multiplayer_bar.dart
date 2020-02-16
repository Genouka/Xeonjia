import 'dart:async';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Bar shown in multi-player mode
// It shows team points and timer
class MultiplayerBar extends StatefulWidget {
  final _MultiplayerBarState state = _MultiplayerBarState();

  @override
  _MultiplayerBarState createState() => state;
}

class _MultiplayerBarState extends State<MultiplayerBar> {
  Timer _timer;
  int remaining = game.maxTime;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (game?.pause ?? true) return;
      setState(() {
        if (--remaining <= 0) {
          _timer.cancel();
          game.end(); // It shouldn't be here
        } else if (game.teams.first.points > game.maxPoints ||
            game.teams.last.points > game.maxPoints) {
          game.end();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Container(
          child: Center(child: Text(game.teams.first.points.toString())),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              border: Border.all(color: game.teams.first.color)),
        )),
        Expanded(
            child:
                Container(child: Center(child: Text((remaining.toString()))))),
        Expanded(
            child: Container(
          child: Center(child: Text(game.teams.last.points.toString())),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              border: Border.all(color: game.teams.last.color)),
        )),
      ]);

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
