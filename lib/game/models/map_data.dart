import 'package:flame/image_composition.dart';

// Map information taken from kingdom.world and maps-data.json
class MapData {
  MapData(Map<String, dynamic> json)
      : fileName = json['fileName'],
        height = json['height'] / 16,
        width = json['width'] / 16,
        x = json['x'] / 16,
        y = json['y'] / 16,
        name = json['name'],
        text = json['text'];

  final String fileName;
  final double height;
  final double width;
  final double x;
  final double y;
  final String? name;
  final String? text;

  // Variables used to adjust size and position to match map.png
  static const double scale = 2.4;
  static final Vector2 offset = Vector2(37, 160);
}
