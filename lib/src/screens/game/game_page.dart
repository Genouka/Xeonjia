import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/resources/weapon_details.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';
import 'package:xeonjia/src/screens/game/widgets/gamepad.dart';
import 'package:xeonjia/src/screens/game/widgets/percent_indicator.dart';

// Top bar percent indicator that shows player life points
LinearPercentIndicator lifePointsBar;

// Bottom bar percent indicator that shows active weapon details
LinearPercentIndicator weaponBar;

// BuildContext of GamePage
BuildContext gameContext;

// Width of the buttons beside weaponBar
const double _bottomBarButtonWidth = 50;

class GamePage extends StatefulWidget {
  final GameMode mode;
  GamePage(this.mode);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    // Initialize top and bottom bars
    lifePointsBar = LinearPercentIndicator(
      width: screenDimensions.width - 2 * _bottomBarButtonWidth,
    );
    weaponBar = LinearPercentIndicator(
      width: screenDimensions.width - 2 * _bottomBarButtonWidth,
    );

    // Initialize game variable
    game = XeonjiaGame(widget.mode);

    // Manage gestures input
    Offset panGestureOffset;
    Flame.util.addGestureRecognizer(TapGestureRecognizer()
      ..onTapDown = (TapDownDetails evt) {
        if (settings.inputMethod == 0 && game != null) {
          game.gestureTapInput(evt.globalPosition);
        }
      });
    Flame.util.addGestureRecognizer(PanGestureRecognizer()
      ..onUpdate = (DragUpdateDetails upd) {
        if (settings.inputMethod == 0 && !(game?.pause ?? true)) {
          if (upd.delta.dx.abs() > 5 || upd.delta.dy.abs() > 5) {
            if (upd.delta.dx.abs() > upd.delta.dy.abs()) {
              panGestureOffset = Offset(upd.delta.dx, 0);
            } else {
              panGestureOffset = Offset(0, upd.delta.dy);
            }
            player?.updateOrientation(panGestureOffset.dx, panGestureOffset.dy);
          }
        }
      }
      ..onEnd = (DragEndDetails end) {
        if (settings.inputMethod == 0 && !(game?.pause ?? true)) {
          game?.gestureDragInput(panGestureOffset);
        }
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    gameContext = context;
    return WillPopScope(
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: SizedBox(
                      height: 40,
                      child: Row(children: [
                        Container(
                            width: _bottomBarButtonWidth,
                            color: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                _pauseDialog(context, mode: 2);
                              },
                              icon: Icon(Icons.close),
                              color: Colors.black,
                              tooltip: 'Exit game',
                            )),
                        lifePointsBar,
                        Container(
                            width: _bottomBarButtonWidth,
                            color: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                _pauseDialog(context, mode: 0);
                              },
                              icon: Icon(Icons.pause),
                              color: Colors.black,
                              tooltip: 'Pause',
                            )),
                      ]))),
              body: Hero(
                tag: 'Play',
                child: Container(
                    color: Colors.lightBlue[50],
                    child: Stack(children: <Widget>[
                      game.widget,
                      if (settings.inputMethod == 1) FloatingGamepad(),
                    ])),
              ),
              bottomNavigationBar: mainCharacter.jsonWeaponList.length > 1
                  ? SizedBox(
                      height: 40,
                      child: Row(children: [
                        Container(
                            width: _bottomBarButtonWidth,
                            color: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                player.nextWeapon();
                                weaponBar.state.refresh(
                                    percent: player.selectedWeapon.powerPoints /
                                        (10 + 5 * player.selectedWeapon.level)
                                            .toDouble(),
                                    text: (weaponDetails[player
                                                ?.selectedWeapon?.id]['name'] ??
                                            '') +
                                        (player?.selectedWeapon?.powerPoints
                                                    ?.isFinite ??
                                                false
                                            ? ' (${player?.selectedWeapon?.powerPoints?.round().toString()})'
                                            : ''));
                              },
                              icon: Icon(Icons.swap_horiz),
                              color: Colors.black,
                              tooltip: 'Change weapon',
                            )),
                        weaponBar,
                        Container(
                            width: _bottomBarButtonWidth,
                            color: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                player.selectedWeapon.shoot(shooter: player);
                              },
                              icon: Icon(Icons.whatshot),
                              color: Colors.black,
                              splashColor: Colors.lightBlue[700],
                              tooltip: 'Hit',
                            )),
                      ]))
                  : Container(
                      height: 40,
                      width: _bottomBarButtonWidth,
                      color: Colors.white,
                      child: MaterialButton(
                        onPressed: () {
                          player.selectedWeapon.shoot(shooter: player);
                        },
                        splashColor: Colors.lightBlue[700],
                        child: Text(
                          'Punch!',
                          style: TextStyle(fontSize: kTextFontSize),
                        ),
                      )),
            ),
          ),
        ),
        onWillPop: () => _pauseDialog(context, mode: 2));
  }

  // Return a string that contains pause dialog texts
  List<Map<String, String>> _pauseDialogStringsListGenerator() => [
        // Pause (mode == 0)
        {
          'title':
              'Pause - Room ${mainCharacter.visitedRooms.last.toString().padLeft(3, '0')}',
          'text': '''
          \n • Moves: ${player.movesCounter.toString()}
          \n • Minutes played: ${((game.currentTime() - game.startDate) / 60).round()}
          \n • Money earned: ${player.earnedMoney.toString()}
          \n • Lifepoints: ${player.lifePoints.round().toString()}
          \n • Poison quantity: ${player.poisonQuantity.round().toString()}
          \n • Enemies killed: ${player.killedEnemies.toString()}
          \n • Exp gained: ${player.experiencePoints.toString()}
          ''',
        },
        // Restart (mode == 1)
        {
          'title': 'Restart match',
          'text': 'Are you sure you wish to restart this game?',
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
  Future<bool> _pauseDialog(BuildContext context, {@required int mode}) {
    game.pause = true;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              List<Map<String, String>> pauseDialogModeList =
                  _pauseDialogStringsListGenerator();
              return WillPopScope(
                  onWillPop: () => null,
                  child: AlertDialog(
                    title: Text(pauseDialogModeList[mode]['title']),
                    content: Text(pauseDialogModeList[mode]['text']),
                    actions: <Widget>[
                      mode == 0
                          ? FlatButton(
                              child: const Text('Restart'),
                              onPressed: () {
                                setState(() {
                                  mode = 1;
                                });
                              })
                          : null,
                      mode == 0
                          ? FlatButton(
                              child: const Text('Exit'),
                              onPressed: () {
                                setState(() {
                                  mode = 2;
                                });
                              })
                          : null,
                      mode == 0
                          ? FlatButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                game.pause = false;
                              })
                          : null,
                      mode != 0
                          ? FlatButton(
                              child: const Text('Yes'),
                              onPressed: () {
                                if (mode == 1) {
                                  game.initialize();
                                } else {
                                  Navigator.pop(context);
                                  game = null;
                                }
                                Navigator.of(context).pop(true);
                              })
                          : null,
                      mode != 0
                          ? FlatButton(
                              child: const Text('No'),
                              onPressed: () {
                                game.pause = false;
                                return Navigator.of(context).pop(false);
                              })
                          : null,
                    ],
                  ));
            }));
  }
}
