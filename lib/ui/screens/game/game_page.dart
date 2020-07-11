import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/ui/screens/game/widgets/dialogs.dart';
import 'package:xeonjia/ui/screens/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/util/screen_dimension.dart';

class GamePage extends StatefulWidget {
  final MatchConfig config;
  GamePage(this.config);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with GameDialogs {
  @override
  void initState() {
    // Initialize game variable
    game = XeonjiaGame(
      widget.config,
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
