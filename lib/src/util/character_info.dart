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

  get experiencePoints => _experiencePoints;
  get experienceRequired => (level + 1) * (level + 1) * 500;
  get experienceRemaining => experienceRequired - experiencePoints;

  // Import character data from a Json
  CharacterInfo(Map<String, dynamic> json)
      : this.name = json['name'] ?? 'yourName',
        this.imageName = json['imageName'] ?? 'character-1.png',
        this.level = json['level'] ?? 0,
        this.money = json['money'] ?? 0,
        this.jsonWeaponList = jsonDecode(json['jsonWeaponList'] ?? '{"0": 0}'),
        this.jsonAvailableWeaponList =
            jsonDecode(json['jsonAvailableWeaponList'] ?? '{}'),
        this.doorKeyList = (json['doorKeyList'] ?? []).cast<int>(),
        this.objectList = (json['objectList'] ?? []).cast<int>(),
        this.totalEarnedMoney = json['totalEarnedMoney'] ?? 0,
        this.visitedRooms = (json['viewedRooms'] ?? [1]).cast<int>(),
        this.minutesPlayed = json['minutesPlayed'] ?? 0,
        this.killedComponents = json['killedComponents'] ?? 0,
        this.movesCounter = json['movesCounter'] ?? 0,
        this.deathCounter = json['deathCounter'] ?? 0,
        this._experiencePoints = json['experiencePoints'] ?? 0;

  // Export character data as a Json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageName': imageName,
      'level': level,
      'money': money,
      'jsonWeaponList': jsonEncode(jsonWeaponList),
      'jsonAvailableWeaponList': jsonEncode(jsonAvailableWeaponList),
      'doorKeyList': doorKeyList,
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

  // Increase experience points earned
  // Return true if level up, false otherwise
  bool expGained(int exp) {
    _experiencePoints += exp;
    if (_experiencePoints >= experienceRequired) {
      _experiencePoints = 0;
      ++level;
      return true;
    } else
      return false;
  }
}
