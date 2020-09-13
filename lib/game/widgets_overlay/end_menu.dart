import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';

class EndMenu extends StatelessWidget {
  final int _lostMoney;
  EndMenu([this._lostMoney = 0]);

  @override
  Widget build(BuildContext context) {
    String title;
    var content = '';
    List<Widget> actions;
    actions = [
      FlatButton(
        child: Text(
          game.config.mode == GameMode.story ? 'Continue' : 'Yes',
          style: const TextStyle(color: Colors.white, fontSize: 32),
        ),
        onPressed: () {
          game.init();
          game.removeWidgetOverlay('endMenu');
        },
      ),
      if (game.config.mode != GameMode.story)
        FlatButton(
          child: const Text(
            'No',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
          onPressed: () {
            Navigator.pop(context);
            game.dispose();
          },
        ),
    ];
    if (game.config.mode == GameMode.story) {
      title = 'You run out of energy !';
      content = 'You lost $_lostMoney ¤ and woke up after a short nap';
    } else {
      title = 'Your team ' +
          (game.ranking.first.id == game.playerOne.teamId ? 'won' : 'lost');
      if (game.remainingTime <= 0) {
        content = 'The time is over.';
      } else {
        content =
            '${game.config.maxPoints.toString()} points have been achieved.';
      }
      content += '\n\nDo you want to restart this game?';
    }

    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 40, letterSpacing: 1.4),
          ),
          Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 32),
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
}
