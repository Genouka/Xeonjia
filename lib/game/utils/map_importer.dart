import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/models/tile.dart';
import 'package:xeonjia/game/utils/tile_to_component.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/local_data_controller.dart';
import 'package:xml/xml.dart';

// Import map from a TMX file
Future<void> importMap(XeonjiaGame gameRef, String fileName) async {
  var mapXml =
      XmlDocument.parse(await rootBundle.loadString(fileName)).rootElement;

  // Get map information
  gameRef.map
    ..width = int.parse(mapXml.getAttribute('width')!)
    ..height = int.parse(mapXml.getAttribute('height')!);

  // Get map properties
  var mapProperties = mapXml.findElements('properties');
  if (mapProperties.isNotEmpty) {
    for (final property in mapProperties.single.children) {
      if (property.attributes.isEmpty) continue;
      switch (property.getAttributeNode('name')!.value) {
        case 'action':
          gameRef.map.action =
              property.getAttributeNode('value')?.value ?? property.text;
          break;
        case 'music':
          gameRef.map.music = property.getAttributeNode('value')!.value;
          break;
        case 'map-name':
          gameRef.map.name = property.getAttributeNode('value')!.value;
          break;
        case 'disable-minimap':
          gameRef.map.disableMiniMap =
              property.getAttributeNode('value')!.value == 'true';
          break;
      }
    }
  }

  // tileId : Tile
  var tileMap = <int, Tile>{};

  // Read tilesets
  await Future.forEach(mapXml.findElements('tileset'),
      (XmlElement tilesetElement) async {
    var firstGid = int.parse(tilesetElement.getAttribute('firstgid')!);

    XmlElement tileset = (tilesetElement.getAttribute('source') == null)
        ? tilesetElement
        : XmlDocument.parse(await rootBundle.loadString(
                'assets/maps/story/' + tilesetElement.getAttribute('source')!))
            .rootElement;

    var tileHeight = double.parse(tileset.getAttribute('tileheight')!);
    var tileCount = int.parse(tileset.getAttribute('tilecount')!);
    var columns = int.parse(tileset.getAttribute('columns')!);

    var image = tileset
        .findElements('image')
        .single
        .getAttribute('source')!
        .split('../../images/')
        .last;
    var spriteSheet = SpriteSheet(
        srcSize: Vector2.all(16), image: Flame.images.fromCache(image));

    // Get tiles from tileset
    if (tileset.findElements('tile').isEmpty) {
      // Used for object groups
      // Properties are defined in objectgroup
      for (var i = 0; i < tileCount; i++) {
        var newTile = Tile(gid: firstGid + i);
        newTile.sprite = spriteSheet.getSprite(i ~/ columns, i % columns);
        newTile.properties['imageY'] =
            ((newTile.gid! - firstGid) / columns).floor() * tileHeight;
        newTile.properties['image'] = image;
        tileMap[newTile.gid!] = newTile;
      }
    } else {
      tileset.findElements('tile').forEach((tile) {
        var newTile = Tile(
          gid: int.parse(tile.getAttribute('id')!) + firstGid,
          type: tile.getAttribute('type'),
        );
        newTile.properties['imageY'] =
            ((newTile.gid! - firstGid) / columns).floor() * tileHeight;
        newTile.properties['image'] = image;
        newTile.sprite = spriteSheet.getSprite(
            (newTile.gid! - firstGid) ~/ columns,
            (newTile.gid! - firstGid) % columns);

        // Read tile properties
        var properties = tile.findElements('properties');
        if (properties.isNotEmpty) {
          for (final property in properties.single.children) {
            if (property.attributes.isNotEmpty) {
              newTile.properties[property.getAttributeNode('name')!.value] =
                  property.getAttributeNode('value')?.value ?? property.text;
            }
          }
        }

        // Load animation
        var animation = tile.findElements('animation');
        if (animation.isNotEmpty) {
          animation.single.findElements('frame').forEach((frame) {
            var id = int.parse(frame.getAttributeNode('tileid')!.value);
            // All frames have the same duration (it uses the last value)
            newTile.animationStepTime =
                double.parse(frame.getAttributeNode('duration')!.value) / 1000;
            newTile.animationSprites
                .add(spriteSheet.getSprite(id ~/ columns, id % columns));
          });
        }

        tileMap[newTile.gid!] = newTile;
      });
    }
  });

  var layerCount = 0;
  mapXml.findElements('layer').forEach((layer) {
    var mapData = <int>[];
    var gzipMapData = layer.findElements('data').single.text;
    var m = gzip.decode(base64.decode(gzipMapData.trim()));
    for (var i = 0; i < m.length; i += 4) {
      mapData.add(m[i] + (m[i + 1] << 8) + (m[i + 2] << 16) + (m[i + 3] << 16));
    }

    var lineCount = 0;
    var columnCount = 0;
    for (final tileId in mapData) {
      var componentTile = tileMap[tileId];
      if (componentTile != null) {
        componentTile.position = Point(columnCount, lineCount);
        componentTile.layer = layerCount;
        componentTile.createComponent(gameRef);
      }
      ++columnCount;
      if (columnCount == gameRef.map.width) {
        columnCount = 0;
        ++lineCount;
      }
    }
    layerCount++;
  });

  // Read objectgroups
  Tile? mainDoor;
  bool playerOneCreated = false;
  mapXml.findElements('objectgroup').forEach((objectgroup) {
    objectgroup.findElements('object').forEach((object) {
      var isTileObject = object.getAttribute('gid') != null;
      var tile = isTileObject
          ? tileMap[int.parse(object.getAttribute('gid')!)]
          : Tile();
      var x = int.parse(object.getAttributeNode('x')!.value) / 16;
      var y = int.parse(object.getAttributeNode('y')!.value) / 16 -
          (isTileObject ? 1 : 0);
      var properties = <String, dynamic>{};
      object
          .findElements('properties')
          .single
          .findElements('property')
          .forEach((property) {
        properties[property.getAttributeNode('name')!.value] =
            property.getAttributeNode('value')?.value ?? property.text;
      });
      tile!.type ??=
          object.getAttribute('type') ?? object.getAttribute('class');
      tile.position = Point(x, y);
      tile.properties.addAll(properties);
      // Add itemId value even if properties['itemId'] == null
      tile.properties['itemId'] = properties['itemId'];
      tile.id = int.parse(object.getAttribute('id')!);
      if (tile.type == 'Door') {
        var previousRoomId = (mainCharacter.visitedRooms.length <= 1)
            ? '0'
            : mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2];
        if (previousRoomId.split('/').first +
                (mainCharacter.visitedRooms.last.contains('/')
                    ? '/' + mainCharacter.visitedRooms.last.split('/').last
                    : '') ==
            tile.properties['roomId']) {
          tile.properties['isPlayerOne'] = true;
          playerOneCreated = true;
        }
        if (tile.properties['mainDoor'] == 'true') mainDoor = tile;
      }
      tile.createComponent(gameRef);
    });
  });
  if (!playerOneCreated) {
    mainDoor
      ?..properties['isPlayerOne'] = true
      ..createComponent(gameRef);
  }
}
