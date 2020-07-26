import 'package:xeonjia/models/message.dart';

// Map properties read from the tmx file
class MapProperties {
  // Map size
  int height;
  int width;

  // Map message (defined in map property "message")
  Message message;

  MapProperties({this.width, this.height, this.message});
}
