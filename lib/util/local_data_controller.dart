import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xeonjia/models/item.dart';
import 'package:xeonjia/models/settings.dart';
import 'package:xeonjia/models/character_info.dart';

SharedPreferences _prefs;

// Stored app settings
Settings settings;

// Main character data
CharacterInfo mainCharacter;

// List of all items
// itemId : Item info
Map<String, Item> itemData = {};

// Gamepad position
Offset gamepadOffset;

// Import all data from shared preferences
Future<void> loadStoredData() async {
  _prefs = await SharedPreferences.getInstance();
  _loadUserData();
  _loadSettings();
  _loadItems();
}

// Save user data in shared preferences
void saveUserData() {
  _prefs.setString('userData_V2', jsonEncode(mainCharacter.toJson()));
}

// Load user data from shared preferences
void _loadUserData() {
  mainCharacter =
      CharacterInfo(jsonDecode(_prefs.getString('userData_V2') ?? '{}'));
}

// Save app settings in shared preferences
void saveSettings() {
  _prefs.setString('settings_V2', jsonEncode(settings.toJson()));
}

// Restore app settings
void _loadSettings() {
  settings = Settings(jsonDecode(_prefs.getString('settings_V2') ?? '{}'));
}

// Load items from assets
void _loadItems() async {
  var data =
      json.decode(await rootBundle.loadString('assets/maps/story/data.json'));
  data['items'].forEach((key, value) {
    itemData[key] = Item(value);
  });
}
