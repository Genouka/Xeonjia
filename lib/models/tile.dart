import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Class used to manage a single tile
class Tile {
  Tile({
    this.id,
    this.gid,
    this.type,
    Map<String, dynamic>? properties,
    this.sprite,
    this.size,
    this.animationSprites,
    this.animationStepTime,
    this.position,
    this.layer,
  }) {
    this.properties = properties ?? {};
    size ??= componentSize;
    animationSprites ??= [];
  }

  // Tile id and gid defined in the TMX file
  int? id;
  int? gid;

  // Component type
  String? type;

  // List of tile properties
  // Properties define component features and stats (eg: atk, def, lifePoints)
  late Map<String, dynamic> properties;

  // Component sprite
  Sprite? sprite;

  // Component size
  double? size;

  // Component animation
  List<Sprite>? animationSprites;
  double? animationStepTime;

  // Tile position
  Point? position;

  // Map layer
  int? layer;
}
