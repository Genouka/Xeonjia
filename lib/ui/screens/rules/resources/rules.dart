import 'package:flutter/material.dart';
import 'package:xeonjia/ui/screens/rules/util/rule.dart';
import 'package:xeonjia/util/i18n.dart';

// Global rules
List<Rule> rules() => [
      Rule(
        title: 'X E O N J i A',
        subtitle:
            'Solve ice puzzles and defeat enemies in an RPG world.\n\nSwipe right to learn the basic concepts.'
                .i18n,
        image: 'assets/graphics/icon_black.png',
      ),
      Rule(
        title: 'Modes'.i18n,
        subtitle:
            'There are two modes in Xeonjia:\n\n1) Story: the world has been frozen and your duty is to defeat the "King of Evil" and save the kingdom.\n\n2) Multiplayer: defeat enemies, score points and make your team win.'
                .i18n,
        icon: Icons.filter_2,
      ),
      Rule(
        title: 'Movements'.i18n,
        subtitle:
            "Swipe your finger to move your character across the world.\nKeep in mind that you can't stop yourself until you reach a wall, a boulder, or any other type of obstacle.\n\nUse your mind to figure out the best path!"
                .i18n,
        icon: Icons.games,
      ),
      Rule(
        title: 'Lifepoints'.i18n,
        subtitle:
            'Pay attention to your lifepoints!\nMany enemies, pitfalls and dangers will try to hurt you.'
                .i18n,
        icon: Icons.favorite_border,
      ),
      Rule(
        title: 'Weapons'.i18n,
        subtitle:
            "You'll need weapons to overcome barriers and defeat enemies.\n\nTap the screen in the desired direction or press the shoot button to hit.\nBe aware that some weapons have few hits, so use them wisely."
                .i18n,
        icon: Icons.whatshot,
      ),
      Rule(
        title: 'Enemies'.i18n,
        subtitle:
            'Be careful, the world is full of dangerous enemies ready to attack you!\nHit them several times to defeat them; they have life points too.'
                .i18n,
        icon: Icons.adjust,
      ),
    ];
