import 'dart:convert';

import 'package:xeonjia/game/util/weapon.dart';

// Class used to manage player data
class CharacterInfo {
  // Import character data from a Json
  CharacterInfo(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        eventLog = jsonDecode(json['eventLog'] ?? '{}'),
        atk = json['atk'] ?? 1,
        def = json['def'] ?? 0,
        maxLifePoints = json['maxLifePoints'] ?? 100,
        currentLifePoints = json['currentLifePoints'] ?? 0,
        poisonQuantity = json['poisonQuantity'] ?? 0,
        money = json['money'] ?? 0,
        itemList = (json['itemList'] ?? []).cast<String>(),
        selectedWeaponIndex = json['selectedWeaponIndex'] ?? 0,
        visitedRooms = (json['viewedRooms'] ?? ['1_home_2']).cast<String>(),
        minutesPlayed = json['minutesPlayed'] ?? 0,
        defeatedComponents = json['defeatedComponents'] ?? 0,
        movesCounter = json['movesCounter'] ?? 0,
        defeatsCounter = json['defeatsCounter'] ?? 0 {
    List<dynamic> jsonWeaponList =
        jsonDecode(json['weaponList'] ?? '[{"id": 0, "lv": 0}]');
    for (final weapon in jsonWeaponList) {
      weaponList.add(Weapon.fromJson(weapon));
    }
  }

  // Name of the character
  String name;

  // Player stats
  double atk;
  double def;
  double maxLifePoints;

  // Player current status
  double currentLifePoints;
  double poisonQuantity;

  // Store story events (eg. things done, info acquired)
  // event name : value (bool or int)
  Map<String, dynamic> eventLog;

  // Available money
  int money;

  // Total number of minutes played by the character in this game
  double minutesPlayed;

  // Total number of enemies defeated by the character
  int defeatedComponents;

  // Number of moves done by the character
  int movesCounter;

  // Number of defeats of the character
  int defeatsCounter;

  // List of rooms visited by the character ordered by view time
  // A room could be stored more than once in this list
  List<String> visitedRooms;

  // List of items owned by the character
  List<String> itemList;

  // Weapons owned by the character
  List<Weapon> weaponList = [];
  int selectedWeaponIndex;

  // Export character data as a Json
  Map<String, dynamic> toJson() {
    return {
      'eventLog': jsonEncode(eventLog),
      'name': name,
      'atk': atk,
      'def': def,
      'maxLifePoints': maxLifePoints,
      'currentLifePoints': currentLifePoints,
      'poisonQuantity': poisonQuantity,
      'money': money,
      'weaponList': jsonEncode(weaponList.fold(
          <Map>[],
          (previousValue, element) =>
              (((previousValue as List) ?? [])..add(element.toJson())))),
      'selectedWeaponIndex': selectedWeaponIndex,
      'itemList': itemList,
      'viewedRooms': visitedRooms,
      'minutesPlayed': minutesPlayed,
      'defeatedComponents': defeatedComponents,
      'movesCounter': movesCounter,
      'defeatsCounter': defeatsCounter,
    };
  }
}
