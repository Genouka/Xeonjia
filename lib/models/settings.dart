// Class used to store settings data
class Settings {
  // Enable app fullscreen
  bool fullScreen;

  // Selected input method
  int inputMethod;

  // Virtual gamepad dimension
  double gamepadSize;

  // Virtual gamepad shape
  int gamepadShape;

  // True if rules have been read
  bool rulesRead;

  // True if music and sounds should be played
  bool backgroundMusic;
  bool soundEffects;

  // Import settings from a Json
  Settings(Map<String, dynamic> json)
      : fullScreen = json['fullScreen'] ?? true,
        inputMethod = json['inputMethod'] ?? 0,
        gamepadSize = json['gamepadSize'] ?? 50,
        gamepadShape = json['gamepadShape'] ?? 0,
        rulesRead = json['rulesRead'] ?? false,
        backgroundMusic = json['backgroundMusic'] ?? true,
        soundEffects = json['soundEffects'] ?? true;

  // Export settings as a Json
  Map<String, dynamic> toJson() => {
        'fullScreen': fullScreen,
        'inputMethod': inputMethod,
        'gamepadSize': gamepadSize,
        'gamepadShape': gamepadShape,
        'rulesRead': rulesRead,
        'backgroundMusic': backgroundMusic,
        'soundEffects': soundEffects,
      };
}
