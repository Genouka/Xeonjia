import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';

// Bar shown in multiplayer mode. It shows team points and timer
class MultiPlayerBar extends StatefulWidget {
  final int maxTime;
  MultiPlayerBar(this.maxTime);

  final _MultiPlayerBarState state = _MultiPlayerBarState();

  @override
  _MultiPlayerBarState createState() => state;
}

class _MultiPlayerBarState extends State<MultiPlayerBar> {
  int _remaining;

  void refresh(int remaining) {
    setState(() {
      _remaining = remaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _firstTeamPoints = game.teams.first.points;
    var _lastTeamPoints = game.teams.last.points;
    var _firstFlex = _firstTeamPoints;
    var _lastFlex = _lastTeamPoints;
    if (_firstTeamPoints == 0 && _lastTeamPoints == 0) {
      _firstFlex = _lastFlex = 1;
    }

    return Row(
      children: [
        Expanded(
          flex: _firstFlex,
          child: Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Center(
              child: Text(
                _firstTeamPoints.toString(),
                style: const TextStyle(fontSize: 18),
                maxLines: 1,
              ),
            ),
            color: game.teams.first.color.withOpacity(0.4),
          ),
        ),
        Expanded(
          flex: _lastFlex,
          child: Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Center(
              child: Text(
                _lastTeamPoints.toString(),
                style: const TextStyle(fontSize: 18),
                maxLines: 1,
              ),
            ),
            color: game.teams.last.color.withOpacity(0.4),
          ),
        ),
        SizedBox(
          width: 48,
          child: Container(
            child: Center(
                child: Text((_remaining ?? widget.maxTime).toString(),
                    style: const TextStyle(fontSize: 18))),
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
