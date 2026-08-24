import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/ui/themes.dart';

class GamePage extends StatelessWidget {
  final XeonjiaGame _game = XeonjiaGame();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: _game.onWillPop,
      child: Theme(
        data: gameTheme,
        child: Scaffold(
          body: GameWidget(
            key: ValueKey(_game),
            game: _game,
            overlayBuilderMap: _game.overlayMap,
          ),
        ),
      ),
    );
  }
}
