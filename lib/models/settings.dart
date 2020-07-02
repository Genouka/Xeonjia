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

  // Import settings from a Json
  Settings(Map<String, dynamic> json)
      : fullScreen = json['fullScreen'] ?? true,
        inputMethod = json['inputMethod'] ?? 0,
        gamepadSize = json['gamepadSize'] ?? 50,
        gamepadShape = json['gamepadShape'] ?? 0,
        rulesRead = json['rulesRead'] ?? false;

  // Export settings as a Json
  Map<String, dynamic> toJson() => {
        'fullScreen': fullScreen,
        'inputMethod': inputMethod,
        'gamepadSize': gamepadSize,
        'gamepadShape': gamepadShape,
        'rulesRead': rulesRead,
      };
}
