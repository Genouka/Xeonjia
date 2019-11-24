import 'package:flutter/material.dart';

import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/info/info_page.dart';
import 'package:xeonjia/src/screens/rules/rules_page.dart';
import 'package:xeonjia/src/screens/settings/settings_page.dart';
import 'package:xeonjia/src/screens/stats/stats_page.dart';
import 'package:xeonjia/src/screens/user/user_page.dart';

// List of available pages displayed in home page
final List<Map<String, dynamic>> pageList = [
  {
    'title': 'Play',
    'subtitle': 'Continue story mode',
    'page': GamePage(),
    'icon': Icon(Icons.play_arrow),
    'gameMode': 1,
  },
  /*
  {
    'title': 'Arena',
    'subtitle': 'Multi-player match versus CPU', // eg TDM, CTF, ...
    'page': ,
    'icon': Icon(Icons.group),
    'gameMode': 1,
  },
  */
  {
    'divider': 'Character',
  },
  {
    'title': 'Your character',
    'subtitle': 'View and edit your character',
    'page': UserPage(appBarCollapsed: true),
    'icon': Icon(Icons.person_pin),
  },
  {
    'divider': 'Stats & Rules',
  },
  {
    'title': 'Stats',
    'subtitle': 'View stats',
    'page': StatsPage(),
    'icon': Icon(Icons.show_chart),
  },
  {
    'title': 'How to play',
    'subtitle': 'Learn how to play',
    'page': RulesPage(),
    'icon': Icon(Icons.description),
  },
  {
    'divider': 'About and settings',
  },
  {
    'title': 'Settings',
    'subtitle': 'Change settings',
    'page': SettingsPage(),
    'icon': Icon(Icons.settings),
  },
  {
    'title': 'Info',
    'subtitle': 'About this game',
    'page': InfoPage(),
    'icon': Icon(Icons.info),
  },
];
