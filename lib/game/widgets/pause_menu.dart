import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/ui/basic.dart';

// i18n: 'pause'.i18n, 'restart'.i18n, 'exit'.i18n
enum PauseMode { pause, restart, exit }

// In-game pause menu
class PauseMenu extends StatefulWidget {
  final PauseMode mode;
  const PauseMenu(this.mode);

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
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  describeEnum(pauseMode).i18n.toUpperCase(),
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
          ),
          divider(context),
          Expanded(
            child: Center(
              child: ScrollConfiguration(
                behavior: NoGlow(),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          divider(context),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: Wrap(alignment: WrapAlignment.center, children: actions),
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
        describeEnum(pauseMode).i18n.toUpperCase(),
        () {
          if (pauseMode == PauseMode.restart) {
            game.overlays.remove('pauseMenu');
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
          game.overlays.remove('pauseMenu');
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
                ? ('\n' + // 'level: %s'.i18n
                    'money: %s ¤'.i18n.fill([game.playerOne.money]) +
                    '\n' +
                    'gems: %s'.i18n.fill([game.playerOne.gemCount]) +
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
          actionButton(
            'restart'.i18n.toUpperCase(),
            () {
              setState(() {
                pauseMode = PauseMode.restart;
                reloadInfo();
              });
            },
          ),
          actionButton('resume'.i18n.toUpperCase(), () {
            game.overlays.remove('pauseMenu');
            game.resume();
          }),
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
}
