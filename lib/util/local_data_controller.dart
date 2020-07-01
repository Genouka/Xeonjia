import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xeonjia/models/settings.dart';

import 'package:xeonjia/resources/global_variables.dart';
import 'package:xeonjia/models/character_info.dart';

SharedPreferences _prefs;

// Stored app settings
AppSettings settings;

// Import all data from shared preferences
Future<void> loadStoredData() async {
  _prefs = await SharedPreferences.getInstance();
  _loadUserData();
  _loadSettings();
}

// Save user data in shared preferences
void saveUserData() {
  _prefs.setString('userData', jsonEncode(mainCharacter.toJson()));
}

// Load user data from shared preferences
void _loadUserData() {
  mainCharacter =
      CharacterInfo(jsonDecode(_prefs.getString('userData') ?? '{}'));
}

// Save app settings in shared preferences
void saveSettings() {
  _prefs.setString('settings', jsonEncode(settings.toJson()));
}

// Save gamepad offset in shared preferences
void saveGamepadOffset() {
  _prefs.setDouble('gamepadOffsetX', kGamepadOffset.dx);
  _prefs.setDouble('gamepadOffsetY', kGamepadOffset.dy);
}

// Restore app settings
void _loadSettings() {
  settings = AppSettings(jsonDecode(_prefs.getString('settings') ?? '{}'));
  kGamepadOffset = Offset(_prefs.getDouble('gamepadOffsetX') ?? 0,
      _prefs.getDouble('gamepadOffsetY') ?? 0);
}
