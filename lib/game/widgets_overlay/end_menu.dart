import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';

class EndMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String title;
    var content = '';
    List<Widget> actions;
    actions = [
      FlatButton(
        child: const Text('Yes'),
        onPressed: () {
          game.init();
          game.removeWidgetOverlay('endMenu');
        },
      ),
      FlatButton(
        child: const Text('No'),
        onPressed: () {
          Navigator.pop(context);
          game.dispose();
        },
      ),
    ];
    if (game.config.mode == GameMode.story) {
      title = 'You have been deleted';
    } else {
      title = 'Your team ' +
          (game.ranking.first.id == game.playerOne.teamId ? 'won' : 'lost');
      if (game.remainingTime <= 0) {
        content = 'The time is over.';
      } else {
        content =
            '${game.config.maxPoints.toString()} points have been achieved.';
      }
    }
    content += '\n\nDo you want to restart this game?';

    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, letterSpacing: 1.4),
          ),
          Text(
            content,
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
}
