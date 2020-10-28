import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/rules/util/rule.dart';

// Global rules
List<Rule> rules() => [
      Rule(
        title: 'X E O N J i A',
        subtitle:
            'Solve ice puzzles and defeat enemies in an RPG world.\n\nSwipe to right to learn the basic concepts.',
        image: 'assets/graphics/icon_black.png',
      ),
      Rule(
        title: 'Modes',
        subtitle: '''There are two modes in Xeonjia:

1) Story: the world has been frozen and your duty is to defeat the "King of Evil" and save the
world.

2) Multiplayer: the aim of this mode is to score points and make your team win.''',
        icon: Icons.filter_2,
      ),
      Rule(
        title: 'Movements',
        subtitle:
            'Swipe your finger to move your character across the world.\nKeep in mind that you can\'t stop yourself until you reach a wall, a boulder, or any other type of obstacle.\n\nUse your mind to figure out the best path!',
        icon: Icons.games,
      ),
      Rule(
        title: 'Lifepoints',
        subtitle:
            'Pay attention to your lifepoints!\nMany enemies, pitfalls and dangers will try to hurt you.',
        icon: Icons.favorite_border,
      ),
      Rule(
        title: 'Weapons',
        subtitle:
            '''You'll need weapons to overcome barriers and defeat enemies.

Tap the screen in the desired direction or press the shoot button to hit.
Be aware that some weapons have few hits, so use them wisely.
    ''',
        icon: Icons.whatshot,
      ),
      Rule(
        title: 'Enemies',
        subtitle:
            '''Be careful, the world is full of dangerous enemies ready to attack you!

Hit them several times with your weapons to defeat them; they have life points too.
    ''',
        icon: Icons.adjust,
      ),
    ];
