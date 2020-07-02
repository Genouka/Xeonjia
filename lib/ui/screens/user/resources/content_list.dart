import 'package:xeonjia/util/local_data_controller.dart';

// Generate list of character stats
List<Map<String, String>> characterStatsListGenerator() => [
      {
        'name': 'Life',
        'value': (100 + 5 * mainCharacter.level).toString(),
      },
      {
        'name': 'Attack',
        'value': (mainCharacter.level + 1).toString(),
      },
      {
        'name': 'Defense',
        'value': (mainCharacter.level ~/ 5).toString(),
      },
    ];
