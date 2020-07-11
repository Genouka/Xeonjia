import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/ui/screens/game/widgets/dialogs.dart';
import 'package:xeonjia/ui/screens/game/widgets/virtual_gamepad.dart';
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
                VirtualGamePad(),
                game.messageBox,
                game.infoBox,
              ],
            ),
          );
        }),
        onWillPop: () => pauseDialog(context, dialogMode: 2));
  }
}
