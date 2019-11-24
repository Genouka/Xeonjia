// Class used to store settings data
class AppSettings {
  // Enable app fullscreen
  bool fullScreen;

  // Selected input method
  int inputMethod;

  // Virtual gamepad dimension
  double gamepadSize;

  // Virtual gamepad shape
  int gamepadShape;

  // Import settings from a Json
  AppSettings(Map<String, dynamic> json)
      : this.fullScreen = json['fullScreen'] ?? true,
        this.inputMethod = json['inputMethod'] ?? 0,
        this.gamepadSize = json['gamepadSize'] ?? 50,
        this.gamepadShape = json['gamepadShape'] ?? 0;

  // Export settings as a Json
  Map<String, dynamic> toJson() => {
        'fullScreen': fullScreen,
        'inputMethod': inputMethod,
        'gamepadSize': gamepadSize,
        'gamepadShape': gamepadShape,
      };
}
