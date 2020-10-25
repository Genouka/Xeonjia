import 'package:flutter/material.dart';

// Linear gradient used in app
final appGradient = LinearGradient(colors: [
  Colors.blue[900],
  Colors.blue[800],
  Colors.blue[700],
  Colors.blue[600],
  Colors.blue[500],
], begin: Alignment.topLeft, end: Alignment.bottomRight);

// Circular radius
const circularRadius = BorderRadius.all(Radius.circular(30));

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
