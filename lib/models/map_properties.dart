// Map properties read from the tmx file
class MapProperties {
  // Map size
  int height;
  int width;

  // Map action (eg. show map-name)
  String action;

  MapProperties({this.width, this.height, this.action});
}
