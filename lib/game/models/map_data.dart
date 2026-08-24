import 'package:flame/image_composition.dart';

/// Map information taken from kingdom.world and maps-data.json
class MapData {
  MapData(Map<String, dynamic> json)
    : id = json['fileName'].split('.').first,
      fileName = json['fileName'],
      height = json['height'] / 16,
      width = json['width'] / 16,
      x = json['x'] / 16,
      y = json['y'] / 16,
      text = json['text'],
      hidden = json['hidden'] ?? false;

  final String id;
  final String fileName;
  final double height;
  final double width;
  final double x;
  final double y;
  final String? text;
  final bool hidden;

  /// Variables used to adjust size and position to match map.png
  /// Offset: 1.tmx position on map.png (4, 18) / map.size (100, 70)
  /// Scale : 6: 1.tmx width on map.png; 20: 1.tmx width; 4.3: scale factor
  static final Vector2 offset = Vector2(4 / 100, 18 / 70);
  static const double scale = 6 / 20 / 4.3;
}
