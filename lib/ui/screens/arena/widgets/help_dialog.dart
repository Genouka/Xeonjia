import 'package:flutter/material.dart';

Widget helpDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Multiplayer Mode', textAlign: TextAlign.center),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('''
The aim of this mode is to score points and make your team win.

The rules are simple:
- The players are organized into two teams.
- Whenever a player defeats an opponent, his team scores 100 points.
- The team that reaches the required score wins.

Your teammates are the red ones.

For now it is possible to play against CPUs.

Choose the place to play and configure the game.
When you are ready press "Play".
        '''),
      ],
    ),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: const Text('Okay, got it!'),
      ),
    ],
  );
}
