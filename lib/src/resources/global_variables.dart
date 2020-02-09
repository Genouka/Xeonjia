import 'package:flutter/material.dart';

import 'package:xeonjia/src/util/app_settings.dart';
import 'package:xeonjia/src/util/character_info.dart';

// App version
const String appVersion = '1.0.1';

// App font size
const double kTextFontSize = 20;

// Screen dimensions
Size screenDimensions;

// Stored app settings
AppSettings settings = AppSettings({});

// Gamepad position
Offset kGamepadOffset;

// Main player data
// In-game data is managed by "player" variable in xeonjia_game.dart
CharacterInfo mainCharacter = CharacterInfo({});

// Game modes
enum GameMode { story, tdm, ctf }
