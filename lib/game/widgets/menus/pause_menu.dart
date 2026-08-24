import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';
import 'package:xeonjia/ui/themes.dart';

// i18n: 'pause'.i18n, 'restart'.i18n, 'exit'.i18n
enum PauseMode { pause, restart, exit }

/// In-game pause menu
class PauseMenu extends StatefulWidget {
  PauseMenu(this.game, this.mode);
  final XeonjiaGame game;
  final PauseMode mode;

  @override
  final GlobalKey<State<PauseMenu>> key = GlobalKey();
  PauseMenuState? get state => key.currentState as PauseMenuState?;

  @override
  State<PauseMenu> createState() => PauseMenuState();
}

class PauseMenuState extends State<PauseMenu> {
  /// Pause mode. It is also the title of this menu
  PauseMode? pauseMode;

  /// Text inside the central box
  late String text;

  /// Buttons
  late List<Widget> buttons;

  /// Currently selected option (for keyboard input)
  int selectedOptionIndex = 0;

  @override
  void initState() {
    reloadInfo();
    super.initState();
  }

  /// Select the next option
  void selectNextOption() {
    setState(() {
      if (++selectedOptionIndex >= buttons.length) selectedOptionIndex = 0;
      reloadInfo();
    });
  }

  /// Select the previous option
  void selectPreviousOption() {
    setState(() {
      if (--selectedOptionIndex < 0) selectedOptionIndex = buttons.length - 1;
      reloadInfo();
    });
  }

  /// Choose the currently selected option
  void chooseOption() {
    setState(() {
      (buttons[selectedOptionIndex] as InkWell).onTap!();
      selectedOptionIndex = 0;
      reloadInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black87),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        pauseMode!.name.i18n.toUpperCase(),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                ),
                divider(context),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: ScrollConfiguration(
                      behavior: NoGlow(),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                divider(context),
                Expanded(
                  flex: 2,
                  child: Center(child: Wrap(children: buttons)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Reload [text] and [buttons]
  void reloadInfo() {
    pauseMode ??= widget.mode;
    buttons = [
      actionButton(
        (selectedOptionIndex == 0 ? '> ' : '') +
            pauseMode!.name.i18n.toUpperCase(),
        () {
          if (pauseMode == PauseMode.restart) {
            widget.game.overlays.remove('pauseMenu');
            widget.game.start();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      actionButton(
        (selectedOptionIndex == 1 ? '> ' : '') + 'cancel'.i18n.toUpperCase(),
        () {
          setState(() {
            pauseMode = PauseMode.pause;
            reloadInfo();
          });
        },
      ),
    ];
    switch (pauseMode!) {
      case PauseMode.pause:
        text =
            'You have %s HP and %s ¤.'.i18n.fill([
              widget.game.playerOne!.hp.round().toString(),
              widget.game.playerOne!.money,
            ]) +
            (widget.game.inBattle &&
                    widget.game.milla != null &&
                    widget.game.milla!.teamId == 0 &&
                    widget.game.milla!.hp > 0
                ? '\n' +
                      'Milla has %s HP.'.i18n.fill([
                        widget.game.milla!.hp.round().toString(),
                      ])
                : '') +
            (widget.game.inBattle &&
                    widget.game.september != null &&
                    widget.game.september!.teamId == 0 &&
                    widget.game.september!.hp > 0
                ? ' ' +
                      'September has %s HP.'.i18n.fill([
                        widget.game.september!.hp.round().toString(),
                      ])
                : '') +
            '\n\n' +
            'What do you want to do?'.i18n;
        buttons = [
          actionButton(
            (selectedOptionIndex == 0 ? '> ' : '') +
                'resume'.i18n.toUpperCase(),
            () {
              widget.game.overlays.remove('pauseMenu');
              widget.game.resume();
            },
          ),
          actionButton(
            (selectedOptionIndex == 1 ? '> ' : '') + 'exit'.i18n.toUpperCase(),
            () {
              setState(() {
                pauseMode = PauseMode.exit;
                reloadInfo();
              });
            },
          ),
          actionButton(
            (selectedOptionIndex == 2 ? '> ' : '') +
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
        text =
            'Are you sure you want to restart this game?'.i18n +
            '\n\n' +
            'It will restart from the last location change.'.i18n;
        break;
      case PauseMode.exit:
        text =
            'Are you sure you want to quit this game?'.i18n +
            '\n\n' +
            'Game data since the last location change will be lost.'.i18n;
    }
  }
}

InkWell actionButton(String text, VoidCallback onPressed) => InkWell(
  onTap: onPressed,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: gameTheme.textTheme.bodyMedium,
    ),
  ),
);

Widget divider(BuildContext context) => Container(
  height: 3,
  width: MediaQuery.of(context).size.width / 1.5,
  constraints: const BoxConstraints(maxWidth: 600),
  decoration: const BoxDecoration(
    color: Colors.white24,
    borderRadius: BorderRadius.all(Radius.circular(30)),
  ),
);
