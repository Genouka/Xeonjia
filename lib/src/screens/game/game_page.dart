import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';
import 'package:xeonjia/src/screens/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/src/screens/game/widgets/multiplayer_bar.dart';
import 'package:xeonjia/src/screens/game/widgets/percent_indicator.dart';
import 'package:xeonjia/src/util/utils.dart';

// Top and bottom bars
LinearPercentIndicator lifePointsBar;
LinearPercentIndicator weaponBar;
MultiPlayerBar multiPlayerBar;

// BuildContext of GamePage
BuildContext gameContext;

// Width of the buttons beside weaponBar
const double _bottomBarButtonWidth = 50;

// True if weapon buttons (change weapon and shot) should be displayed
bool _weaponButtonVisibility;

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
    // Initialize top and bottom bars
    lifePointsBar = LinearPercentIndicator(
      width: screenWidth - 2 * _bottomBarButtonWidth,
    );
    weaponBar = LinearPercentIndicator(
      width: screenWidth - 2 * _bottomBarButtonWidth,
    );
    if (widget.mode == GameMode.story) {
      _weaponButtonVisibility = mainCharacter.jsonWeaponList.length > 1;
    } else {
      _weaponButtonVisibility = true;
      multiPlayerBar = MultiPlayerBar(widget.maxTime);
    }

    // Initialize game variable
    game = XeonjiaGame(widget.mode,
        teamSize: widget.teamSize,
        friendlyFire: widget.friendlyFire,
        maxTime: widget.maxTime,
        maxPoints: widget.maxPoints,
        difficulty: widget.difficulty,
        mapId: widget.mapId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    gameContext = context;

    return WillPopScope(
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: OrientationBuilder(builder: (context, orientation) {
              setScreenDimension(context);
              game.updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize:
                      Size.fromHeight(game.mode == GameMode.story ? 40 : 80),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Container(
                              width: _bottomBarButtonWidth,
                              color: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  _pauseDialog(context, dialogMode: 2);
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                                tooltip: 'Exit game',
                              ),
                            ),
                            lifePointsBar,
                            Container(
                              width: _bottomBarButtonWidth,
                              color: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  _pauseDialog(context, dialogMode: 0);
                                },
                                icon: Icon(Icons.pause),
                                color: Colors.black,
                                tooltip: 'Pause',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (game.mode != GameMode.story)
                        SizedBox(height: 40, child: multiPlayerBar),
                    ],
                  ),
                ),
                body: Hero(
                  tag: 'Play',
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        game.widget,
                        if (settings.inputMethod != 0)
                          VirtualGamepad(
                              manageMovements: settings.inputMethod == 1),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: _weaponButtonVisibility
                    ? SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Container(
                              width: _bottomBarButtonWidth,
                              color: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  playerOne.nextWeapon();
                                  weaponBar.state.refresh(
                                    percent:
                                        playerOne.selectedWeapon.powerPoints /
                                            (10 +
                                                    5 *
                                                        playerOne.selectedWeapon
                                                            .level)
                                                .toDouble(),
                                    text: (playerOne?.selectedWeapon?.name ??
                                            '') +
                                        (playerOne?.selectedWeapon?.powerPoints
                                                    ?.isFinite ??
                                                false
                                            ? ' (${playerOne?.selectedWeapon?.powerPoints?.round().toString()})'
                                            : ''),
                                  );
                                },
                                icon: Icon(Icons.swap_horiz),
                                color: Colors.black,
                                tooltip: 'Change weapon',
                              ),
                            ),
                            weaponBar,
                            Container(
                              width: _bottomBarButtonWidth,
                              color: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  playerOne.selectedWeapon
                                      .shoot(shooter: playerOne);
                                },
                                icon: Icon(Icons.whatshot),
                                color: Colors.black,
                                splashColor: Colors.lightBlue[700],
                                tooltip: 'Shoot',
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 40,
                        width: _bottomBarButtonWidth,
                        color: Colors.white,
                        child: MaterialButton(
                          onPressed: () {
                            playerOne.selectedWeapon.shoot(shooter: playerOne);
                          },
                          splashColor: Colors.lightBlue[700],
                          child: const Text(
                            'Punch!',
                            style: TextStyle(fontSize: kTextFontSize),
                          ),
                        ),
                      ),
              );
            }),
          ),
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
    game.pause = true;
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          List<Map<String, String>> pauseDialogModeList =
              _pauseDialogStringsListGenerator();
          return WillPopScope(
            onWillPop: () => null,
            child: AlertDialog(
              title: Text(pauseDialogModeList[dialogMode]['title']),
              content: Text(pauseDialogModeList[dialogMode]['text']),
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
                          game.pause = false;
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
                          game.pause = false;
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
