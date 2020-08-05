import 'package:flutter/material.dart';

import 'package:xeonjia/util/screen_dimension.dart';

// Map name shown on the top right of the screen
class MapBox extends StatelessWidget {
  final String text;
  MapBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        width: screenSize.width / 2.5,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
            color: Colors.grey[800].withOpacity(0.7),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Text(
          '~ $text ~',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }
}
