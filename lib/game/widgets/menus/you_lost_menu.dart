import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

class YouLostMenu extends StatelessWidget {
  const YouLostMenu(this.game, this.callback, [this._lostMoney = 0]);
  final XeonjiaGame game;
  final VoidCallback callback;
  final int _lostMoney;

  @override
  Widget build(BuildContext context) {
    String title;
    var content = '';
    title = 'You run out of energy !'.i18n;
    content = 'You lost %s ¤ and woke up after a short nap'.i18n.fill([
      '$_lostMoney',
    ]);

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
                onPressed: callback,
                child: Text(
                  '> ' + 'Continue'.i18n,
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
