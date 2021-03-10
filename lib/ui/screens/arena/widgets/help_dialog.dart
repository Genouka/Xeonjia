import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';

Widget helpDialog(BuildContext context) {
  return AlertDialog(
    title: Text('Multiplayer Mode'.i18n, textAlign: TextAlign.center),
    content: SingleChildScrollView(
      child: Text(
          '''The aim of this mode is to defeat enemies, score points and make your team win.\n\nThe rules are simple:\n- The players are organized into two teams.\n- Whenever a player defeats an opponent, his team scores 100 points.\n- The team that reaches the required score wins.\n\nYour teammates are the red ones.\n\nFor now it's only possible to play against CPUs.\n\nChoose the place to play and configure the game.\nWhen you are ready press "Play".'''
              .i18n),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: Navigator.of(context).pop,
        style: TextButton.styleFrom(primary: Theme.of(context).primaryColor),
        child: Text('Okay, got it!'.i18n),
      ),
    ],
  );
}
