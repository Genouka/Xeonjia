import 'dart:io';
import 'dart:ui';

import 'package:xeonjia/utils/i18n.dart';

/// This contains the configurations of the app
class Settings {
  /// Import settings from a Json
  Settings(Map<String, dynamic> json)
      : showDPad = json['showDPad'] ?? false,
        dPadSize = json['dPadSize'] ?? 1,
        dPadOffset =
            Offset(json['dPadOffsetX'] ?? 30, json['dPadOffsetY'] ?? 30),
        firstRun = json['firstRun'] ?? true,
        backgroundMusic = json['backgroundMusic'] ?? true,
        soundEffects = json['soundEffects'] ?? true,
        _languageCode = json['languageCode'];

  /// Export settings as a Json
  Map<String, dynamic> toJson() => {
        'showDPad': showDPad,
        'dPadSize': dPadSize,
        'dPadOffsetX': dPadOffset.dx,
        'dPadOffsetY': dPadOffset.dy,
        'firstRun': firstRun,
        'backgroundMusic': backgroundMusic,
        'soundEffects': soundEffects,
        'languageCode': _languageCode,
      };

  /// True if D-pad is enabled
  bool showDPad;

  /// True if rules have been read
  bool firstRun;

  /// True if music and sounds should be played
  bool backgroundMusic;
  bool soundEffects;
  bool audioSupported = true;

  /// D-pad dimension and position
  double dPadSize;
  Offset dPadOffset;

  /// App language
  String? _languageCode;
  bool get useSystemLanguage => _languageCode == null;
  String get _currentLanguageCode =>
      useSystemLanguage ? Platform.localeName : _languageCode!;
  Locale get locale => supportedLocales
              .contains(Locale(_currentLanguageCode.split('_').first)) ||
          !useSystemLanguage
      ? Locale(_currentLanguageCode.split('_').first)
      : const Locale('en');
  set locale(Locale? locale) => _languageCode = locale?.toString();

  /// Font used
  String get font =>
      _useExtendedFont ? 'LanaPixel' : (_useSystemFont ? '' : 'dd5x7');
  bool get smallerFont => font != 'dd5x7';
  bool get _useExtendedFont =>
      languagesWithSpecialCharacters.contains(locale.languageCode);
  bool get _useSystemFont =>
      languagesWithNonSupportedCharacters.contains(locale.languageCode);
}
