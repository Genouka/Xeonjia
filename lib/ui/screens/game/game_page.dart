import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/widgets/pause_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/ui/themes.dart';

class GamePage extends StatelessWidget {
  GamePage(MatchConfig config) : _game = XeonjiaGame(config);
  final XeonjiaGame _game;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _game.miniMapEnabled
            ? _game.miniMap()
            : _game.pause(mode: PauseMode.exit);
        return Future.value(false);
      },
      child: Focus(
        onKey: (data, event) => KeyEventResult.handled,
        child: Theme(
          data: gameTheme,
          child: Scaffold(
            body: GameWidget(game: _game, overlayBuilderMap: _game.overlayMap),
          ),
        ),
      ),
    );
  }
}
