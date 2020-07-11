import 'package:flutter/material.dart';
import 'package:xeonjia/models/game_mode.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/ui/screens/game/widgets/dialogs.dart';
import 'package:xeonjia/ui/screens/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/util/screen_dimension.dart';

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

class _GamePageState extends State<GamePage> with GameDialogs {
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
      pauseDialog: () => pauseDialog(context, dialogMode: 0),
      endDialog: endDialog,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: OrientationBuilder(builder: (context, orientation) {
          setScreenDimension(context);
          game.updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
          return Scaffold(
            body: Stack(
              children: <Widget>[
                game.widget,
                game.messageBox,
                game.infoBox,
                if (settings.inputMethod != 0)
                  VirtualGamepad(manageMovements: settings.inputMethod == 1),
              ],
            ),
          );
        }),
        onWillPop: () => pauseDialog(context, dialogMode: 2));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
