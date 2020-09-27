import 'dart:convert';

// Class used to manage player data
class CharacterInfo {
  // Name of the character
  String name;

  // Character image
  String imageName;

  // Player stats
  int level;
  double atk;
  double def;
  double lifePoints;

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

  // Total number of money earned by the character
  int totalEarnedMoney;

  // Total number of minutes played by the character in this game
  double minutesPlayed;

  // Total number of killed enemies by the character
  int killedComponents;

  // Number of moves done by the character
  int movesCounter;

  // Number of deaths of the character
  int deathCounter;

  // List of rooms visited by the character ordered by view time
  // A room could be stored more than once in this list
  List<String> visitedRooms;

  // List of items owned by the character
  List<int> itemList;

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
      : name = json['name'] ?? 'yourName',
        imageName = json['imageName'] ?? 'character-1.png',
        eventLog = jsonDecode(json['eventLog'] ?? '{}'),
        level = json['level'] ?? 0,
        atk = json['atk'] ?? 1,
        def = json['def'] ?? 0,
        lifePoints = json['lifePoints'] ?? 100,
        currentLifePoints = json['currentLifePoints'] ?? 0,
        poisonQuantity = json['poisonQuantity'] ?? 0,
        money = json['money'] ?? 0,
        jsonWeaponList = jsonDecode(json['jsonWeaponList'] ?? '{"0": 0}'),
        jsonAvailableWeaponList =
            jsonDecode(json['jsonAvailableWeaponList'] ?? '{}'),
        itemList = (json['itemList'] ?? []).cast<int>(),
        totalEarnedMoney = json['totalEarnedMoney'] ?? 0,
        visitedRooms = (json['viewedRooms'] ?? ['1']).cast<String>(),
        minutesPlayed = json['minutesPlayed'] ?? 0,
        killedComponents = json['killedComponents'] ?? 0,
        movesCounter = json['movesCounter'] ?? 0,
        deathCounter = json['deathCounter'] ?? 0,
        _experiencePoints = json['experiencePoints'] ?? 0;

  // Export character data as a Json
  Map<String, dynamic> toJson() {
    return {
      'eventLog': jsonEncode(eventLog),
      'name': name,
      'imageName': imageName,
      'level': level,
      'atk': atk,
      'def': def,
      'lifePoints': lifePoints,
      'currentLifePoints': currentLifePoints,
      'poisonQuantity': poisonQuantity,
      'money': money,
      'jsonWeaponList': jsonEncode(jsonWeaponList),
      'jsonAvailableWeaponList': jsonEncode(jsonAvailableWeaponList),
      'itemList': itemList,
      'viewedRooms': visitedRooms,
      'totalEarnedMoney': totalEarnedMoney,
      'minutesPlayed': minutesPlayed,
      'killedComponents': killedComponents,
      'movesCounter': movesCounter,
      'deathCounter': deathCounter,
      'experiencePoints': _experiencePoints,
    };
  }
}
