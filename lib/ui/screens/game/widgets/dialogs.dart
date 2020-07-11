import 'package:flutter/material.dart';
import 'package:xeonjia/models/game_mode.dart';

import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

mixin GameDialogs on State<GamePage> {
  // Return a string that contains pause dialog texts
  List<Map<String, String>> _pauseDialogStringsListGenerator() => [
        // Pause (mode == 0)
        {
          'title': 'Pause - ' +
              (game.config.mode == GameMode.story
                  ? 'Room ${mainCharacter.visitedRooms.last.toString().padLeft(3, '0')}'
                  : modeNames[game.config.mode]),
          'text': '''
          \n • Moves: ${playerOne.movesCounter.toString()}
          \n • Minutes played: ${((game.currentTime() - game.startDate) / 60).round()}
          \n • Lifepoints: ${playerOne.lifePoints.round().toString()}
          \n • Poison quantity: ${playerOne.poisonQuantity.round().toString()}
          \n • Enemies killed: ${playerOne.killedEnemies.toString()}
          ''' +
              (game.config.mode == GameMode.story
                  ? '\n • Money earned: ${playerOne.earnedMoney.toString()}'
                  : '\n • Deaths: ${playerOne.deaths.toString()}') +
              (game.config.mode == GameMode.story
                  ? '\n\n • Exp gained: ${playerOne.experiencePoints.toString()}'
                  : '\n\n • Your points: ${playerOne.points.toString()}'),
        },
        // Restart (mode == 1)
        {
          'title': 'Restart match',
          'text': 'Are you sure you want to restart this game?',
        },
        // Exit (mode == 2)
        {
          'title': 'Exit match',
          'text':
              'Are you sure you want to exit this game? Match data will be lost.',
        },
      ];

  // Dialog that permits to select weapons to bring in game
  // If mode == 0 -> pause menu
  // If mode == 1 -> restart menu
  // If mode == 2 -> exit menu
  Future<bool> pauseDialog(BuildContext context, {@required int dialogMode}) {
    if (game.avoidExit) {
      game.avoidExit = false;
      return Future.value(false);
    }
    game.pause();
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          List pauseDialogModeList = _pauseDialogStringsListGenerator();
          return WillPopScope(
            onWillPop: () => null,
            child: AlertDialog(
              title: Text(pauseDialogModeList[dialogMode]['title']),
              content: SingleChildScrollView(
                  child: Text(pauseDialogModeList[dialogMode]['text'])),
              actions: <Widget>[
                dialogMode == 0
                    ? FlatButton(
                        child: const Text('Restart'),
                        onPressed: () {
                          setState(() {
                            dialogMode = 1;
                          });
                        },
                      )
                    : null,
                dialogMode == 0
                    ? FlatButton(
                        child: const Text('Exit'),
                        onPressed: () {
                          setState(() {
                            dialogMode = 2;
                          });
                        },
                      )
                    : null,
                dialogMode == 0
                    ? FlatButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          game.resume();
                        },
                      )
                    : null,
                dialogMode != 0
                    ? FlatButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          if (dialogMode == 1) {
                            game.initialize();
                          } else {
                            Navigator.pop(context);
                            game = null;
                          }
                          Navigator.of(context).pop(true);
                        },
                      )
                    : null,
                dialogMode != 0
                    ? FlatButton(
                        child: const Text('No'),
                        onPressed: () {
                          game.resume();
                          return Navigator.of(context).pop(false);
                        },
                      )
                    : null,
              ],
            ),
          );
        },
      ),
    );
  }

  // Dialog displayed when the game ends
  void endDialog({bool timeOut}) {
    var title = '';
    var content = '';
    if (game.config.mode == GameMode.story) {
      title = 'You have been deleted';
    } else {
      title = 'Your team ' +
          (game.ranking.first.id == playerOne.teamId ? 'won' : 'lost');
      if (timeOut) {
        content = 'The time is over.';
      } else {
        content =
            '${game.config.maxPoints.toString()} points have been achieved.';
      }
    }
    content += '\n\nDo you want to restart this game?';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () => null,
        child: AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: const Text('Yes'),
              onPressed: () {
                game.initialize();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context);
                game.dispose();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
