import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/ui/basic.dart';

// Floating "PLAY" button
class PlayButton extends StatelessWidget {
  final page;
  PlayButton(this.page);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, borderRadius: circularRadius),
      child: FlatButton(
        shape: const RoundedRectangleBorder(borderRadius: circularRadius),
        child: Text(
          'Play'.i18n.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontSize: 20, letterSpacing: 6),
        ),
        onPressed: () {
          Navigator.push(context, FadeRoute(page()));
        },
      ),
    );
  }
}
