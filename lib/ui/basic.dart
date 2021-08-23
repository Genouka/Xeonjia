import 'package:flutter/material.dart';

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
