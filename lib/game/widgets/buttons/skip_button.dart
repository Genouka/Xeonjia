import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Button used to skip the story if already read
class SkipButton extends StatelessWidget {
  SkipButton(this.game);
  final XeonjiaGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 56,
      right: 6,
      child: InkWell(
        onTap: game.skipStory,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          height: 34,
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withAlpha((255.0 * 0.7).round()),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          child: const Icon(Icons.skip_next_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
