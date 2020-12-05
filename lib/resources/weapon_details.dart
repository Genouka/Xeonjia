import 'package:xeonjia/i18n/ui.i18n.dart';

// List of every weapon available in this game
// id == list index
List<Map<String, dynamic>> weaponDetails() => [
      {
        'id': 0,
        'name': 'Punch'.i18n,
        'description':
            'Hit the enemy in front of you.\nThis is the most basic weapon. You have infite PP.'
                .i18n,
      },
      {
        'id': 1,
        'name': 'SnowBalls',
        'description': 'Throw snowballs in front of you.'.i18n,
      },
      {
        'id': 2,
        'name': 'Mines',
        'description':
            'Leave explosive mines on the floor.\nA mine explodes if someone except you walks on it.'
                .i18n,
      },
    ];
