// Map properties read from the tmx file
class MapProperties {
  // Map id
  final String fullId;
  String get id => fullId.split('/').first;

  // Map name (read from map action)
  String name;

  // Map size
  int height;
  int width;

  // Map action (eg. show map-name)
  String action;

  // Background music
  String music;

  MapProperties(
      {this.fullId, this.width, this.height, this.action, this.music});
}
