import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Class used to manage a single tile
class Tile {
  Tile({
    this.id,
    this.gid,
    this.type,
    Map<String, dynamic>? properties,
    Sprite? sprite,
    this.size,
    this.animationStepTime,
    this.position,
    this.layer,
  }) {
    this.properties = properties ?? {};
    this.sprite = sprite;
    size ??= componentSize;
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
  Sprite? _sprite;
  Sprite get sprite =>
      _sprite ?? Sprite(Flame.images.fromCache('background.png'));
  set sprite(Sprite? sprite) => _sprite = sprite;
  bool get hidden => _sprite == null;

  // Component size
  double? size;

  // Component animation
  List<Sprite> animationSprites = [];
  double? animationStepTime;

  // Tile position
  Point? position;

  // Map layer
  int? layer;
}
