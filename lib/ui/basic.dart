import 'package:flutter/material.dart';
import 'package:xeonjia/ui/themes.dart';

// Page route
class FadeRoute extends PageRouteBuilder {
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

  @override
  final Duration transitionDuration = const Duration(milliseconds: 150);

  final Widget page;
}

// Remove scroll glow
class NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

// Button in pauseMenu and backpackMenu
Widget actionButton(String text, VoidCallback onPressed) => InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: gameTheme.textTheme.bodyText2,
        ),
      ),
    );

// White line that divides children of Columns in pauseMenu and backpackMenu
Widget divider(BuildContext context) => Container(
      height: 3,
      width: MediaQuery.of(context).size.width / 1.5,
      decoration: const BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    );
