import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';

// List of menu items displayed in the info page
final List<Map<String, dynamic>> infoMenuList = [
  {
    'title': 'By DeepDaikon',
    'subtitle': 'App developed by DeepDaikon',
    'url': 'https://gitlab.com/DeepDaikon/',
    'icon': Icon(Icons.change_history),
  },
  {
    'title': 'Version: $appVersion',
    'subtitle': 'App version',
    'url': '',
    'icon': Icon(Icons.looks_one),
  },/*
  {
    'title': 'Updates',
    'subtitle': 'Search for updates on F-Droid',
    'url': 'https://f-droid.org/packages/xyz.deepdaikon.xeonjia/',
    'icon': Icon(Icons.system_update),
  },*/
  {
    'title': 'Changelog',
    'subtitle': 'View app changelog',
    'url': 'https://gitlab.com/DeepDaikon/Xeonjia/blob/master/CHANGELOG',
    'icon': Icon(Icons.playlist_add),
  },
  {
    'title': 'View source code',
    'subtitle': 'Look at the source code',
    'url': 'https://gitlab.com/DeepDaikon/Xeonjia',
    'icon': Icon(Icons.developer_mode),
  },
  {
    'title': 'Report bugs',
    'subtitle': 'Report bugs or request new feature',
    'url': 'https://gitlab.com/DeepDaikon/Xeonjia/issues',
    'icon': Icon(Icons.bug_report),
  },
  {
    'title': 'View License (GPLv3)',
    'subtitle': 'Read software license',
    'url': 'https://gitlab.com/DeepDaikon/Xeonjia/blob/master/LICENSE',
    'icon': Icon(Icons.chrome_reader_mode),
  },
  {
    'title': 'Third Party Licenses',
    'subtitle': 'Read third party notices',
    'url': '',
    'icon': Icon(Icons.code),
  }
];
