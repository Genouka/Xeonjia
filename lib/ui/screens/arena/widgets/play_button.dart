import 'package:flutter/material.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/utils/i18n.dart';

// Floating "PLAY" button
class PlayButton extends StatelessWidget {
  const PlayButton(this.page);
  final Function page;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(30))),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
        ),
        onPressed: () => Navigator.push(context, FadeRoute(page())),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            'Play'.i18n.toUpperCase(),
            maxLines: 1,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, letterSpacing: 6),
          ),
        ),
      ),
    );
  }
}
