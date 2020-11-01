import 'dart:convert';

// Class used to manage player data
class CharacterInfo {
  // Name of the character
  String name;

  // Player stats
  int level;
  double atk;
  double def;
  double maxLifePoints;

  // Player current status
  double currentLifePoints;
  double poisonQuantity;

  // Experience points
  int _experiencePoints;

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

  // Weapons carried by the character
  // Map structure: {weaponId : weaponLevel}
  Map<String, dynamic> jsonWeaponList;

  // Every weapons owned by the character
  // Map structure: {weaponId : weaponLevel}
  Map<String, dynamic> jsonAvailableWeaponList;

  int get experiencePoints => _experiencePoints;
  int get experienceRequired => (level + 1) * (level + 1) * 500;
  int get experienceRemaining => experienceRequired - experiencePoints;

  // Increase experience points earned
  void expGained(int exp) {
    _experiencePoints += exp;
    if (_experiencePoints >= experienceRequired) {
      _experiencePoints = 0;
      ++level;
    }
  }

  // Import character data from a Json
  CharacterInfo(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        eventLog = jsonDecode(json['eventLog'] ?? '{}'),
        level = json['level'] ?? 0,
        atk = json['atk'] ?? 1,
        def = json['def'] ?? 0,
        maxLifePoints = json['maxLifePoints'] ?? 100,
        currentLifePoints = json['currentLifePoints'] ?? 0,
        poisonQuantity = json['poisonQuantity'] ?? 0,
        money = json['money'] ?? 0,
        jsonWeaponList = jsonDecode(json['jsonWeaponList'] ?? '{"0": 0}'),
        jsonAvailableWeaponList =
            jsonDecode(json['jsonAvailableWeaponList'] ?? '{}'),
        itemList = (json['itemList'] ?? []).cast<String>(),
        visitedRooms = (json['viewedRooms'] ?? ['1']).cast<String>(),
        minutesPlayed = json['minutesPlayed'] ?? 0,
        defeatedComponents = json['defeatedComponents'] ?? 0,
        movesCounter = json['movesCounter'] ?? 0,
        defeatsCounter = json['defeatsCounter'] ?? 0,
        _experiencePoints = json['experiencePoints'] ?? 0;

  // Export character data as a Json
  Map<String, dynamic> toJson() {
    return {
      'eventLog': jsonEncode(eventLog),
      'name': name,
      'level': level,
      'atk': atk,
      'def': def,
      'maxLifePoints': maxLifePoints,
      'currentLifePoints': currentLifePoints,
      'poisonQuantity': poisonQuantity,
      'money': money,
      'jsonWeaponList': jsonEncode(jsonWeaponList),
      'jsonAvailableWeaponList': jsonEncode(jsonAvailableWeaponList),
      'itemList': itemList,
      'viewedRooms': visitedRooms,
      'minutesPlayed': minutesPlayed,
      'defeatedComponents': defeatedComponents,
      'movesCounter': movesCounter,
      'defeatsCounter': defeatsCounter,
      'experiencePoints': _experiencePoints,
    };
  }
}
