import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/story.i18n.dart';
import 'package:xeonjia/game/widgets/info_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Map name shown on the top left of the screen
class MapNameBox extends StatelessWidget {
  final String text;
  final bool below;
  MapNameBox({this.below = true}) : text = game.map.name;

  @override
  Widget build(BuildContext context) {
    return text != null
        ? InfoBox(
            below: below,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                text.i18n.toUpperCase(),
                style: Theme.of(context).textTheme.button,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          )
        : Container();
  }
}
