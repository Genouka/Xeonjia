import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xeonjia/game/models/character_info.dart';
import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/models/map_data.dart';
import 'package:xeonjia/utils/settings.dart';

// Game settings and preferences
late SharedPreferences _prefs;
late Settings settings;

// Main character data
late CharacterInfo mainCharacter;

// List of all items
// itemId : Item info
Map<String, Item> itemData = {};

// List of maps (taken from kingdom.world and maps-data.json)
List<MapData> worldData = [];

// Gamepad position
late Offset gamepadOffset;

// Import all data from shared preferences
Future<void> loadStoredData() async {
  _prefs = await SharedPreferences.getInstance();

  // Load user data from shared preferences
  mainCharacter =
      CharacterInfo(jsonDecode(_prefs.getString('userData_V2') ?? '{}'));

  // Restore app settings
  settings = Settings(jsonDecode(_prefs.getString('settings_V2') ?? '{}'));

  // Load items from assets
  var data = json.decode(
      await rootBundle.loadString('assets/maps/data/items-and-events.json'));
  data['items'].forEach((key, value) => itemData[key] =
      Item((value as Map<String, dynamic>)..putIfAbsent('id', () => key)));

  // Load maps data from kingdom.world and maps-data.json
  final List<dynamic> kingdomWorld = json.decode(
      await rootBundle.loadString('assets/maps/story/kingdom.world'))['maps'];
  final Map<String, dynamic> mapsData = json
      .decode(await rootBundle.loadString('assets/maps/data/maps-data.json'));
  for (final map in kingdomWorld) {
    worldData.add(MapData({}
      ..addAll(map)
      ..addAll(mapsData.containsKey(map['fileName'])
          ? mapsData[map['fileName']]
          : {})));
  }
}

// Save user data in shared preferences
void saveUserData() {
  _prefs.setString('userData_V2', jsonEncode(mainCharacter.toJson()));
}

// Save app settings in shared preferences
void saveSettings() {
  _prefs.setString('settings_V2', jsonEncode(settings.toJson()));
}
