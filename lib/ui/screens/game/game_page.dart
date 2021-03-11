import 'package:flutter/material.dart';

import 'package:xeonjia/game/widgets/pause_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/match_config.dart';

class GamePage extends StatelessWidget {
  GamePage(MatchConfig config) {
    game = XeonjiaGame(config);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        game.pause(mode: PauseMode.exit);
        return Future.value(false);
      },
      child: Focus(
        onKey: (data, event) => false,
        child: Theme(
          data: ThemeData(fontFamily: 'm5x7'),
          child: Scaffold(body: game.widget),
        ),
      ),
    );
  }
}
