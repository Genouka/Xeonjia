import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/arena/arena_page.dart';
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
    'page': GamePage(GameMode.story),
    'icon': const Icon(Icons.play_arrow),
  },
  {
    'title': 'Arena',
    'subtitle': 'Multi-player match versus CPU',
    'page': ArenaPage(),
    'icon': const Icon(Icons.group),
  },
  {
    'divider': 'Character',
  },
  {
    'title': 'Your character',
    'subtitle': 'View and edit your character',
    'page': UserPage(appBarCollapsed: true),
    'icon': const Icon(Icons.person_pin),
  },
  {
    'divider': 'Stats & Rules',
  },
  {
    'title': 'Stats',
    'subtitle': 'View story mode stats',
    'page': StatsPage(),
    'icon': const Icon(Icons.show_chart),
  },
  {
    'title': 'How to play',
    'subtitle': 'Learn how to play',
    'page': RulesPage(),
    'icon': const Icon(Icons.description),
  },
  {
    'divider': 'About and settings',
  },
  {
    'title': 'Settings',
    'subtitle': 'Change settings',
    'page': SettingsPage(),
    'icon': const Icon(Icons.settings),
  },
  {
    'title': 'Info',
    'subtitle': 'About this game',
    'page': InfoPage(),
    'icon': const Icon(Icons.info),
  },
];
