import 'package:flutter/material.dart';

import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';

// Floating "PLAY" button
class PlayButton extends StatelessWidget {
  final GamePage page;
  PlayButton(this.page);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, borderRadius: circularRadius),
      child: FlatButton(
        shape: const RoundedRectangleBorder(borderRadius: circularRadius),
        child: const Text(
          'P L A Y',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.push(context, FadeRoute(page));
        },
      ),
    );
  }
}
