import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/game/game_page.dart';

// Linear gradient used in app
LinearGradient appGradient = LinearGradient(colors: [
  Colors.lightBlue[700],
  Colors.lightBlue[400],
  Colors.lightBlue[200],
], begin: Alignment.topLeft, end: Alignment.bottomRight);

// Floating "PLAY" button
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
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.push(context, FadeRoute(page));
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
