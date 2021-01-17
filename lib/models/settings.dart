import 'dart:io';
import 'dart:ui';

import 'package:xeonjia/main.dart';

// Class used to store settings data
class Settings {
  // True if D-pad is enabled
  bool showDPad;

  // True if rules have been read
  bool firstRun;

  // True if music and sounds should be played
  bool backgroundMusic;
  bool soundEffects;

  // App language
  String _languageCode;
  bool get useSystemLanguage => _languageCode == null;
  String get _currentLanguageCode => _languageCode ?? Platform.localeName;
  Locale get locale =>
      supportedLocales.contains(Locale(_currentLanguageCode.split('_').first))
          ? Locale(_currentLanguageCode.split('_').first)
          : const Locale('en');
  set locale(Locale locale) {
    _languageCode = locale?.toString();
  }

  // Import settings from a Json
  Settings(Map<String, dynamic> json)
      : showDPad = json['showDPad'] ?? false,
        firstRun = json['firstRun'] ?? true,
        backgroundMusic = json['backgroundMusic'] ?? true,
        soundEffects = json['soundEffects'] ?? true,
        _languageCode = json['languageCode'];

  // Export settings as a Json
  Map<String, dynamic> toJson() => {
        'showDPad': showDPad,
        'firstRun': firstRun,
        'backgroundMusic': backgroundMusic,
        'soundEffects': soundEffects,
        'languageCode': _languageCode,
      };
}
