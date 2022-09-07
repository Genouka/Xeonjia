import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';

// i18n: 'pause'.i18n, 'restart'.i18n, 'exit'.i18n
enum PauseMode { pause, restart, exit }

/// In-game pause menu
class PauseMenu extends StatefulWidget {
  const PauseMenu(this.gameRef, this.mode);
  final XeonjiaGame gameRef;
  final PauseMode mode;

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  /// Pause mode. It is also the title of this menu
  PauseMode? pauseMode;

  /// Text inside the central box
  late String text;

  /// Buttons
  late List<Widget> buttons;

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
                  pauseMode!.name.i18n.toUpperCase(),
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
              child: Wrap(alignment: WrapAlignment.center, children: buttons),
            ),
          ),
        ],
      ),
    );
  }

  /// Reload [text] and [buttons]
  void reloadInfo() {
    pauseMode ??= widget.mode;
    buttons = [
      actionButton(
        pauseMode!.name.i18n.toUpperCase(),
        () {
          if (pauseMode == PauseMode.restart) {
            widget.gameRef.overlays.remove('pauseMenu');
            widget.gameRef.start();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      actionButton(
        'cancel'.i18n.toUpperCase(),
        () {
          widget.gameRef.overlays.remove('pauseMenu');
          widget.gameRef.resume();
        },
      ),
    ];
    switch (pauseMode!) {
      case PauseMode.pause:
        text = 'HP: %s'
                .i18n
                .fill([widget.gameRef.playerOne!.hp.round().toString()]) +
            (widget.gameRef.config.mode == GameMode.story
                ? ('\n' +
                    'money: %s ¤'.i18n.fill([widget.gameRef.playerOne!.money]) +
                    '\n' +
                    'gems: %s'.i18n.fill([widget.gameRef.playerOne!.gemCount]) +
                    '\n' +
                    'play time: %s min'.i18n.fill(
                        [widget.gameRef.playerOne!.minutesPlayed.round()]))
                : ('\n' +
                    'your defeats: %s'
                        .i18n
                        .fill([widget.gameRef.playerOne!.defeats]) +
                    '\n' +
                    'enemies defeated: %s'
                        .i18n
                        .fill([widget.gameRef.playerOne!.defeatedEnemies]) +
                    '\n' +
                    'your points: %s'
                        .i18n
                        .fill([widget.gameRef.playerOne!.points.toString()])));
        buttons = [
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
            widget.gameRef.overlays.remove('pauseMenu');
            widget.gameRef.resume();
          }),
        ];
        break;
      case PauseMode.restart:
        text = 'Are you sure you want to restart this game?'.i18n;
        if (widget.gameRef.config.mode == GameMode.story) {
          text +=
              '\n\n' + 'It will restart from the last location change.'.i18n;
        }
        break;
      case PauseMode.exit:
        text = 'Are you sure you want to quit this game?'.i18n;
        if (widget.gameRef.config.mode == GameMode.story) {
          text +=
              '\n\nGame data since the last time you changed your location will be lost.'
                  .i18n;
        }
    }
  }
}
