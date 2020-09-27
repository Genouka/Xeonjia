// Map properties read from the tmx file
class MapProperties {
  // Map name
  String fullName;
  String get name => fullName.split('/').first;

  // Map size
  int height;
  int width;

  // Map action (eg. show map-name)
  String action;

  // Background music
  String music;

  MapProperties(
      {this.fullName, this.width, this.height, this.action, this.music});
}
