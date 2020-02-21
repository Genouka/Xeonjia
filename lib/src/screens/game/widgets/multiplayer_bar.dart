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
  int _remaining;

  @override
  void initState() {
    super.initState();
    start();
  }

  // Start widget
  void start() {
    _timer?.cancel();
    _remaining = game?.maxTime ?? 100;
    if (mounted) setState(() {});
    _startTimer();
  }
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if ((game?.pause ?? true) || !mounted) return;
      setState(() {
        if (--_remaining <= 0) {
          _timer.cancel();
          game.end(); // It shouldn't be here
        } else if (game.teams.first.points > game.maxPoints ||
            game.teams.last.points > game.maxPoints) {
          game.end();
        }
      });
    });
  }

  Widget build(BuildContext context) {
    int _firstTeamPoints = game.teams.first.points;
    int _lastTeamPoints = game.teams.last.points;
    int _firstFlex = _firstTeamPoints;
    int _lastFlex = _lastTeamPoints;
    if (_firstTeamPoints == 0 && _lastTeamPoints == 0) {
      _firstFlex = _lastFlex = 1;
    }

    return Row(children: [
      Expanded(
          flex: _firstFlex,
          child: Container(
            child: Center(
                child: Text(
              _firstTeamPoints.toString(),
              style: TextStyle(fontSize: 18),
            )),
            color: game.teams.first.color.withOpacity(0.4),
          )),
      Expanded(
          flex: _lastFlex,
          child: Container(
            child: Center(
                child: Text(
              _lastTeamPoints.toString(),
              style: TextStyle(fontSize: 18),
            )),
            color: game.teams.last.color.withOpacity(0.4),
          )),
      SizedBox(
          width: 50,
          child: Container(
            child: Center(
                child: Text(_remaining.toString(),
                    style: TextStyle(fontSize: 18))),
            color: Colors.white.withOpacity(0.4),
          )),
    ]);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
