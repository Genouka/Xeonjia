import 'dart:convert';

// Class used to manage player data
class CharacterInfo {
  // Name of the character
  String name;

  // Character image
  String imageName;

  // Character level
  int level;

  // Experience points
  int _experiencePoints;

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
  List<int> visitedRooms;

  // List of keys owned by the character
  List<int> doorKeyList;

  // List of objects owned by the character (eg gems)
  List<int> objectList;

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
  // Return true if level up, false otherwise
  bool expGained(int exp) {
    _experiencePoints += exp;
    if (_experiencePoints >= experienceRequired) {
      _experiencePoints = 0;
      ++level;
      return true;
    } else {
      return false;
    }
  }

  // Import character data from a Json
  CharacterInfo(Map<String, dynamic> json)
      : name = json['name'] ?? 'yourName',
        imageName = json['imageName'] ?? 'character-1.png',
        level = json['level'] ?? 0,
        money = json['money'] ?? 0,
        jsonWeaponList = jsonDecode(json['jsonWeaponList'] ?? '{"0": 0}'),
        jsonAvailableWeaponList =
            jsonDecode(json['jsonAvailableWeaponList'] ?? '{}'),
        doorKeyList = (json['doorKeyListV2'] ?? []).cast<int>(),
        objectList = (json['objectList'] ?? []).cast<int>(),
        totalEarnedMoney = json['totalEarnedMoney'] ?? 0,
        visitedRooms = (json['viewedRooms'] ?? [1]).cast<int>(),
        minutesPlayed = json['minutesPlayed'] ?? 0,
        killedComponents = json['killedComponents'] ?? 0,
        movesCounter = json['movesCounter'] ?? 0,
        deathCounter = json['deathCounter'] ?? 0,
        _experiencePoints = json['experiencePoints'] ?? 0;

  // Export character data as a Json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageName': imageName,
      'level': level,
      'money': money,
      'jsonWeaponList': jsonEncode(jsonWeaponList),
      'jsonAvailableWeaponList': jsonEncode(jsonAvailableWeaponList),
      'doorKeyListV2': doorKeyList,
      'objectList': objectList,
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
