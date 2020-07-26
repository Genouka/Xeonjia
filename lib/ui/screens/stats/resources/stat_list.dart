import 'package:xeonjia/util/local_data_controller.dart';

// Generate the list of stats displayed in stats page
List<Map<String, dynamic>> statsListGenerator() => [
      {
        'title': 'Minutes played',
        'subtitle': 'Total number of minutes playes',
        'value': mainCharacter.minutesPlayed.round(),
      },
      {
        'title': 'Moves done',
        'subtitle': 'Total number of moves done',
        'value': mainCharacter.movesCounter,
      },
      {
        'title': 'Rooms visited',
        'subtitle': 'Total number of rooms visited',
        'value': mainCharacter.visitedRooms.toSet().length,
      },
      {
        'title': 'Floors visited',
        'subtitle': 'Total number of floors visited',
        'value':
            // Calculate number of visited floors based on rooms id
            // toSet() is used to have only unique values
            mainCharacter.visitedRooms.map((room) => room ~/ 10).toSet().length,
      },
      {
        'title': 'Money earned',
        'subtitle': 'Total number of money earned',
        'value': mainCharacter.totalEarnedMoney,
      },
      {
        'title': 'Gems owned',
        'subtitle': 'Total number of gems owned',
        'value': mainCharacter.itemList.length,
      },
      {
        'title': 'Defeats',
        'subtitle': 'Total number of defeats',
        'value': mainCharacter.deathCounter,
      },
      {
        'title': 'Enemies killed',
        'subtitle': 'Total number of enemies killed',
        'value': mainCharacter.killedComponents,
      },
    ];
