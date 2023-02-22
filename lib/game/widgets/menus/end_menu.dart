import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';

class EndMenu extends StatelessWidget {
  const EndMenu(this.gameRef, [this._lostMoney = 0]);
  final XeonjiaGame gameRef;
  final int _lostMoney;

  @override
  Widget build(BuildContext context) {
    String title;
    var content = '';
    if (gameRef.config.mode == GameMode.story) {
      title = 'You run out of energy !'.i18n;
      content = 'You lost %s ¤ and woke up after a short nap'
          .i18n
          .fill(['$_lostMoney']);
    } else {
      title = (gameRef.ranking.first.id == gameRef.playerOne!.teamId)
          ? 'Your team won'.i18n
          : 'Your team lost'.i18n;
      content = (gameRef.remainingTime <= 0)
          ? 'The time is over.'.i18n
          : '%s points have been achieved.'
              .i18n
              .fill([gameRef.config.maxPoints.toString()]);
      content += '\n\n' + 'Do you want to restart this game?'.i18n;
    }

    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Container(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  gameRef.start();
                  gameRef.overlays.remove('endMenu');
                },
                child: Text(
                  gameRef.config.mode == GameMode.story
                      ? 'Continue'.i18n
                      : 'Yes'.i18n,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (gameRef.config.mode != GameMode.story)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'No'.i18n,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
