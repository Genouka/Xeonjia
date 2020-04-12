import 'package:flutter/material.dart';

import 'package:xeonjia/src/util/settings.dart';
import 'package:xeonjia/src/util/character_info.dart';

// App version
const String appVersion = '1.2.0';

// App font size
const double kTextFontSize = 20;

// Screen dimensions
double screenWidth;
double screenHeight;

// Stored app settings
AppSettings settings;

// Gamepad position
Offset kGamepadOffset;

// Main character data
CharacterInfo mainCharacter;

// Game modes
enum GameMode { story, tdm, ctf }
const Map<GameMode, String> modeNames = {
  GameMode.story: 'Story Mode',
  GameMode.tdm: 'Team Deathmatch',
  GameMode.ctf: 'Capture the Flag',
};

// Linear gradient used in app
LinearGradient appGradient = LinearGradient(colors: [
  Colors.lightBlue[700],
  Colors.lightBlue[400],
  Colors.lightBlue[200],
], begin: Alignment.topLeft, end: Alignment.bottomRight);
