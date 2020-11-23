// Class used to store settings data
class Settings {
  // True if D-pad is enabled
  bool showDPad;

  // True if rules have been read
  bool firstRun;

  // True if music and sounds should be played
  bool backgroundMusic;
  bool soundEffects;

  // Import settings from a Json
  Settings(Map<String, dynamic> json)
      : showDPad = json['showDPad'] ?? false,
        firstRun = json['firstRun'] ?? true,
        backgroundMusic = json['backgroundMusic'] ?? true,
        soundEffects = json['soundEffects'] ?? true;

  // Export settings as a Json
  Map<String, dynamic> toJson() => {
        'showDPad': showDPad,
        'firstRun': firstRun,
        'backgroundMusic': backgroundMusic,
        'soundEffects': soundEffects,
      };
}
