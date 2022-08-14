// Map properties read from the tmx file
class GameMap {
  GameMap({
    required this.fullId,
    this.width = 0,
    this.height = 0,
    this.action,
    this.music,
    this.disableMiniMap = false,
    this.canEscape = false,
  });

  // Map id
  final String fullId;
  String get id => fullId.split('/').first;

  // Map name (read from map action)
  String? name;

  // Map size
  int height;
  int width;

  // Map action (eg. show map-name)
  String? action;

  // Background music
  String? music;

  // Disable/Enable mini-map (enabled by default)
  bool disableMiniMap;

  // True if playerOne can escape from this room without defeating every enemy
  bool canEscape;
}
