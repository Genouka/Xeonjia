import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/util/local_data_controller.dart';

enum PauseMode { pause, restart, exit }

// In-game pause menu
class PauseMenu extends StatefulWidget {
  final PauseMode mode;
  PauseMenu(this.mode);

  @override
  _PauseMenuState createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  // Pause mode. It is also the title of this menu
  PauseMode pauseMode;

  // Text inside the central box
  String text;

  // Buttons
  List<Widget> actions;

  @override
  void initState() {
    reloadInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              alignment: Alignment.bottomCenter,
              child: Text(
                describeEnum(pauseMode).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          divider,
          Expanded(
            child: Center(
              child: ScrollConfiguration(
                behavior: _NoGlow(),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          divider,
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reload texts and buttons
  void reloadInfo() {
    pauseMode ??= widget.mode;
    actions = [
      actionButton(
        describeEnum(pauseMode).toUpperCase(),
        () {
          if (pauseMode == PauseMode.restart) {
            game.removeWidgetOverlay('pauseMenu');
            game.init();
          } else {
            Navigator.pop(context);
            game.dispose();
          }
        },
      ),
      actionButton(
        'CANCEL',
        () {
          game.removeWidgetOverlay('pauseMenu');
          game.resume();
        },
      ),
    ];
    switch (pauseMode) {
      case PauseMode.pause:
        text = 'lifepoints: ${game.playerOne.lifePoints.round()}\n' +
            (game.config.mode == GameMode.story
                ? '''
            \nyour level: ${game.playerOne.level}
            \nmoney: 0 ¤
            \nplay time: ${mainCharacter.minutesPlayed.round()} min'''
                : '''
            \ndeaths: ${game.playerOne.deaths}
            \nenemies killed: ${game.playerOne.killedEnemies}
            \nyour points: ${game.playerOne.points.toString()}
            ''');
        actions = [
          actionButton(
            'EXIT',
            () {
              setState(() {
                pauseMode = PauseMode.exit;
                reloadInfo();
              });
            },
          ),
          actionButton('RESUME', () {
            game.removeWidgetOverlay('pauseMenu');
            game.resume();
          }),
          actionButton(
            'RESTART',
            () {
              setState(() {
                pauseMode = PauseMode.restart;
                reloadInfo();
              });
            },
          ),
        ];
        break;
      case PauseMode.restart:
        text = 'Are you sure you want to restart this match?';
        if (game.config.mode == GameMode.story) {
          text += '\n\nIt will restart from the last location change.';
        }
        break;
      case PauseMode.exit:
        text = 'Are you sure you want to quit this match?';
        if (game.config.mode == GameMode.story) {
          text +=
              '\n\nMatch data since the last time you changed your location will be lost.';
        }
    }
  }

  // White line that divides the children of the Column
  Widget get divider => Container(
        height: 3,
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: const BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      );

  // Button on the bottom row
  Widget actionButton(String text, VoidCallback onPressed) {
    return FlatButton(
      color: Colors.transparent,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
      onPressed: onPressed,
    );
  }
}

// Remove scroll glow
class _NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
