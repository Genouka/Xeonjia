import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/match_config.dart';

class GamePage extends StatelessWidget {
  final MatchConfig config;

  GamePage(this.config) {
    game = XeonjiaGame(config);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(body: game.widget),
        onWillPop: () => Future.value(true));
  }
}
