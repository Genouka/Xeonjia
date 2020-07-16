import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';

enum PauseMode { Pause, Restart, Exit }

class PauseMenu extends StatefulWidget {
  final PauseMode mode;
  PauseMenu(this.mode);

  @override
  _PauseMenuState createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  PauseMode pauseMode;
  String text;
  List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    _getInfo();
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pauseMode.toString().split('.').last.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 32, letterSpacing: 1.4),
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Container(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions,
          ),
        ],
      ),
    );
  }

  void _getInfo() {
    pauseMode ??= widget.mode;
    actions = [
      FlatButton(
        color: Colors.white54,
        child: const Text('Yes'),
        onPressed: () {
          if (pauseMode == PauseMode.Restart) {
            game.removeWidgetOverlay('pauseMenu');
            game.init();
          } else {
            Navigator.pop(context);
            game.dispose();
          }
        },
      ),
      FlatButton(
        color: Colors.white54,
        child: const Text('No'),
        onPressed: () {
          game.removeWidgetOverlay('pauseMenu');
          game.resume();
        },
      ),
    ];
    switch (pauseMode) {
      case PauseMode.Pause:
        text = '''
          \nMoves: ${playerOne.movesCounter.toString()}
          \nMinutes played: ${(game.elapsedSeconds / 60).round()}
          \nLifepoints: ${playerOne.lifePoints.round().toString()}
          \nPoison quantity: ${playerOne.poisonQuantity.round().toString()}
          \nEnemies killed: ${playerOne.killedEnemies.toString()}
          ''' +
            (game.config.mode == GameMode.story
                ? '\nMoney earned: ${playerOne.earnedMoney.toString()}'
                : '\nDeaths: ${playerOne.deaths.toString()}') +
            (game.config.mode == GameMode.story
                ? '\n\nExp gained: ${playerOne.experiencePoints.toString()}'
                : '\n\nYour points: ${playerOne.points.toString()}');
        actions = [
          FlatButton(
            color: Colors.white54,
            child: const Text('Restart'),
            onPressed: () {
              setState(() {
                pauseMode = PauseMode.Restart;
              });
            },
          ),
          FlatButton(
            color: Colors.white54,
            child: const Text('Exit'),
            onPressed: () {
              setState(() {
                pauseMode = PauseMode.Exit;
              });
            },
          ),
          FlatButton(
              color: Colors.white54,
              child: const Text('Resume'),
              onPressed: () {
                game.removeWidgetOverlay('pauseMenu');
                game.resume();
              })
        ];
        break;
      case PauseMode.Restart:
        text = 'Are you sure you want to restart this game?';
        break;
      case PauseMode.Exit:
        text =
            'Are you sure you want to exit this game? Match data will be lost.';
    }
  }
}
