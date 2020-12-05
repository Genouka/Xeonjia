import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/game.i18n.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';

// i18n: 'pause'.i18n, 'restart'.i18n, 'exit'.i18n
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
                describeEnum(pauseMode).i18n.toUpperCase(),
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
        'cancel'.i18n.toUpperCase(),
        () {
          game.removeWidgetOverlay('pauseMenu');
          game.resume();
        },
      ),
    ];
    switch (pauseMode) {
      case PauseMode.pause:
        text = 'lifepoints: %s'
                .i18n
                .fill([game.playerOne.lifePoints.round().toString()]) +
            (game.config.mode == GameMode.story
                ? ('\n' +
                    'your level: %s'.i18n.fill([game.playerOne.level]) +
                    '\n' +
                    'money: %s ¤'.i18n.fill([game.playerOne.money]) +
                    '\n' +
                    'play time: %s min'
                        .i18n
                        .fill([game.playerOne.minutesPlayed.round()]))
                : ('\n' +
                    'your defeats: %s'.i18n.fill([game.playerOne.defeats]) +
                    '\n' +
                    'enemies defeated: %s'
                        .i18n
                        .fill([game.playerOne.defeatedEnemies]) +
                    '\n' +
                    'your points: %s'
                        .i18n
                        .fill([game.playerOne.points.toString()])));
        actions = [
          actionButton(
            'exit'.i18n.toUpperCase(),
            () {
              setState(() {
                pauseMode = PauseMode.exit;
                reloadInfo();
              });
            },
          ),
          actionButton('resume'.i18n.toUpperCase(), () {
            game.removeWidgetOverlay('pauseMenu');
            game.resume();
          }),
          actionButton(
            'restart'.i18n.toUpperCase(),
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
        text = 'Are you sure you want to restart this game?'.i18n;
        if (game.config.mode == GameMode.story) {
          text +=
              '\n\n' + 'It will restart from the last location change.'.i18n;
        }
        break;
      case PauseMode.exit:
        text = 'Are you sure you want to quit this game?'.i18n;
        if (game.config.mode == GameMode.story) {
          text +=
              '\n\nGame data since the last time you changed your location will be lost.'
                  .i18n;
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
