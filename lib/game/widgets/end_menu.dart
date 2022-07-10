import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/util/i18n.dart';

class EndMenu extends StatelessWidget {
  const EndMenu([this._lostMoney = 0]);
  final int _lostMoney;

  @override
  Widget build(BuildContext context) {
    String title;
    var content = '';
    if (game!.config.mode == GameMode.story) {
      title = 'You run out of energy !'.i18n;
      content = 'You lost %s ¤ and woke up after a short nap'
          .i18n
          .fill(['$_lostMoney']);
    } else {
      title = (game!.ranking.first.id == game!.playerOne!.teamId)
          ? 'Your team won'.i18n
          : 'Your team lost'.i18n;
      content = (game!.remainingTime <= 0)
          ? 'The time is over.'.i18n
          : '%s points have been achieved.'
              .i18n
              .fill([game!.config.maxPoints.toString()]);
      content += '\n\n' + 'Do you want to restart this game?'.i18n;
    }

    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          Container(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  game!.start();
                  game!.overlays.remove('endMenu');
                },
                child: Text(
                  game!.config.mode == GameMode.story
                      ? 'Continue'.i18n
                      : 'Yes'.i18n,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              if (game!.config.mode != GameMode.story)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    game!.dispose();
                  },
                  child: Text(
                    'No'.i18n,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
