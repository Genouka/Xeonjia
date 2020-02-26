import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';

// Floating "PLAY" button
// Used for single and multiplayer mode
class PlayButton extends StatelessWidget {
  final GamePage page;

  // Gradient color
  final bool gradient;

  PlayButton({@required this.page, @required this.gradient});

  static const BorderRadius fabBorderRadius =
      BorderRadius.all(Radius.circular(30));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
          gradient: gradient ? appGradient : null,
          color: gradient ? null : Colors.lightBlue[700],
          borderRadius: fabBorderRadius),
      child: FlatButton(
        shape: const RoundedRectangleBorder(borderRadius: fabBorderRadius),
        child: const Text(
          'P L A Y',
          style: TextStyle(color: Colors.white, fontSize: kTextFontSize),
        ),
        onPressed: () {
          Navigator.push(
            context,
            FadeRoute(page),
          );
        },
      ),
    );
  }
}

// Page route
class FadeRoute extends PageRouteBuilder {
  @override
  final Duration transitionDuration = const Duration(milliseconds: 150);

  final Widget page;
  FadeRoute(this.page)
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(opacity: animation, child: child),
        );
}
