import 'package:flutter/material.dart';
import 'package:xeonjia/models/game_mode.dart';

import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/util/screen_dimension.dart';

// BuildContext of GamePage
BuildContext gameContext;

class GamePage extends StatefulWidget {
  final GameMode mode;
  final int teamSize;
  final int maxTime;
  final int maxPoints;
  final int mapId;
  final int difficulty;
  final bool friendlyFire;
  GamePage(this.mode,
      {this.teamSize = 0,
      this.maxTime = 0,
      this.maxPoints = 0,
      this.mapId = 0,
      this.difficulty = 0,
      this.friendlyFire = false});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    // Initialize game variable
    game = XeonjiaGame(
      widget.mode,
      teamSize: widget.teamSize,
      friendlyFire: widget.friendlyFire,
      maxTime: widget.maxTime,
      maxPoints: widget.maxPoints,
      difficulty: widget.difficulty,
      mapId: widget.mapId,
      pauseDialog: () => _pauseDialog(context, dialogMode: 0),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    gameContext = context;

    return WillPopScope(
        child: Container(
          color: Colors.white,
          child: OrientationBuilder(builder: (context, orientation) {
            setScreenDimension(context);
            game.updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
            return Scaffold(
              body: Hero(tag: 'Play', child: game.widget),
            );
          }),
        ),
        onWillPop: () => _pauseDialog(context, dialogMode: 2));
  }

  // Return a string that contains pause dialog texts
  List<Map<String, String>> _pauseDialogStringsListGenerator() => [
        // Pause (mode == 0)
        {
          'title': 'Pause - ' +
              (game.mode == GameMode.story
                  ? 'Room ${mainCharacter.visitedRooms.last.toString().padLeft(3, '0')}'
                  : modeNames[game.mode]),
          'text': '''
          \n • Moves: ${playerOne.movesCounter.toString()}
          \n • Minutes played: ${((game.currentTime() - game.startDate) / 60).round()}
          \n • Lifepoints: ${playerOne.lifePoints.round().toString()}
          \n • Poison quantity: ${playerOne.poisonQuantity.round().toString()}
          \n • Enemies killed: ${playerOne.killedEnemies.toString()}
          ''' +
              (game.mode == GameMode.story
                  ? '\n • Money earned: ${playerOne.earnedMoney.toString()}'
                  : '\n • Deaths: ${playerOne.deaths.toString()}') +
              (game.mode == GameMode.story
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
  Future<bool> _pauseDialog(BuildContext context, {@required int dialogMode}) {
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
