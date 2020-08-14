import 'package:flutter/material.dart';
import 'package:xeonjia/game/widgets_overlay/info_box.dart';

// Map name shown on the top left of the screen
class MapBox extends StatelessWidget {
  final String text;
  MapBox(this.text);

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      opacity: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }
}
