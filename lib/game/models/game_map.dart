/// Map properties read from the tmx file
class GameMap {
  GameMap({
    required this.fullId,
    this.width = 0,
    this.height = 0,
    this.action,
    this.music,
    this.milla,
    this.disableMiniMap = false,
    this.disableWorldMap = false,
    this.canEscape = true,
    this.hasHints = false,
    this.startBattle = true,
  });

  /// Map id
  final String fullId;
  String get id => fullId.split('/').first;

  /// Map name (read from map action)
  String? name;

  /// Map size
  int height;
  int width;

  /// Map action (eg. show map-name)
  String? action;

  /// Background music
  String? music;

  /// Milla's dialogs
  List<String>? milla;

  /// Disable/Enable mini-map (enabled by default)
  bool disableMiniMap;

  /// Disable/Enable world-map (enabled by default)
  bool disableWorldMap;

  /// True if [playerOne] can escape from this room without defeating every enemy
  bool canEscape;

  /// True if this map has hints (arrows on the ground)
  bool hasHints;

  /// True if game.startBattle() is called immediately
  /// If false, (start-battle) procedure must be used
  bool startBattle;
}
