import 'dart:math';
import 'package:flame/sprite.dart';

import 'package:xeonjia/game/xeonjia_game.dart';

// Class used to manage a single tile
class Tile {
  // Tile ID defined in the TMX file
  int id;

  // Component type
  String type;

  // List of tile properties
  // Properties define component features and stats (eg: atk, def, lifePoints)
  Map<String, dynamic> properties;

  // Component sprite
  Sprite sprite;

  // Component size
  double size;

  // Tile position
  Point position;

  // Map layer
  int layer;

  Tile({
    this.id,
    this.type,
    this.properties,
    this.sprite,
    this.size,
    this.position,
    this.layer,
  }) {
    properties ??= {};
    size ??= componentSize;
  }
}
