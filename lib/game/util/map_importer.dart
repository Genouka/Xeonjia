import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import 'package:xeonjia/game/util/tile_to_component.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/tile.dart';

// Import map from a TMX file
Future<void> importMap(String fileName) async {
  var mapXml =
      XmlDocument.parse(await rootBundle.loadString(fileName)).rootElement;

  // Get map information
  game.map
    ..width = int.parse(mapXml.getAttribute('width'))
    ..height = int.parse(mapXml.getAttribute('height'));

  // Add map background
  game.addLater(SpriteComponent.fromSprite(game.map.width * componentSize,
      game.map.height * componentSize, Sprite('background.png')));

  // Get map properties
  var mapProperties = mapXml.findElements('properties');
  if (mapProperties.isNotEmpty) {
    mapProperties.single.children.forEach((property) {
      if (property.attributes.isNotEmpty &&
          property.getAttributeNode('name').value == 'action') {
        game.map.action =
            property.getAttributeNode('value')?.value ?? property.text;
      } else if (property.attributes.isNotEmpty &&
          property.getAttributeNode('name').value == 'music') {
        game.map.music = property.getAttributeNode('value').value;
      } else if (property.attributes.isNotEmpty &&
          property.getAttributeNode('name').value == 'disable-minimap') {
        game.map.disableMiniMap =
            property.getAttributeNode('value').value == 'true';
      }
    });
  }

  // tileId : Tile
  var _tileMap = <int, Tile>{};

  // Read tilesets
  await Future.forEach(mapXml.findElements('tileset'), (tilesetElement) async {
    var firstGid = int.parse(tilesetElement.getAttribute('firstgid'));

    XmlElement tileset = (tilesetElement.getAttribute('source') == null)
        ? tilesetElement
        : XmlDocument.parse(await rootBundle.loadString(
                'assets/maps/story/' + tilesetElement.getAttribute('source')))
            .rootElement;

    var tileHeight = double.parse(tileset.getAttribute('tileheight'));
    var tileCount = int.parse(tileset.getAttribute('tilecount'));
    var columns = int.parse(tileset.getAttribute('columns'));

    var image = tileset
        .findElements('image')
        .single
        .getAttribute('source')
        .split('../../images/')
        .last;
    await Flame.images.load(image);
    var spriteSheet = SpriteSheet(
        imageName: image,
        textureWidth: 16,
        textureHeight: 16,
        columns: columns,
        rows: tileCount ~/ columns);

    // Get tiles from tileset
    if (tileset.findElements('tile').isEmpty) {
      // Used for object groups
      // Properties are defined in objectgroup
      for (var i = 0; i < tileCount; i++) {
        var newTile = Tile(gid: firstGid + i);
        newTile.sprite = spriteSheet.getSprite(i ~/ columns, i % columns);
        newTile.properties['imageY'] =
            (((newTile.gid - firstGid) / columns).floor() * tileHeight);
        newTile.properties['image'] = image;
        _tileMap[newTile.gid] = newTile;
      }
    } else {
      tileset.findElements('tile').forEach((tile) {
        var newTile = Tile(
          gid: int.parse(tile.getAttribute('id')) + firstGid,
          type: tile.getAttribute('type'),
        );
        newTile.properties['imageY'] =
            (((newTile.gid - firstGid) / columns).floor() * tileHeight);
        newTile.properties['image'] = image;
        newTile.sprite = spriteSheet.getSprite(
            (newTile.gid - firstGid) ~/ columns,
            (newTile.gid - firstGid) % columns);

        // Read tile properties
        var properties = tile.findElements('properties');
        if (properties.isNotEmpty) {
          properties.single.children.forEach((property) {
            if (property.attributes.isNotEmpty) {
              newTile.properties[property.getAttributeNode('name').value] =
                  property.getAttributeNode('value')?.value ?? property.text;
            }
          });
        }
        _tileMap[newTile.gid] = newTile;
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
    game.playerOne = null;
    mapData.forEach((tileId) {
      var componentTile = _tileMap[tileId];
      if (componentTile != null) {
        componentTile.position = Point(
            componentTile.size * columnCount, componentTile.size * lineCount);
        componentTile.layer = layerCount;
        componentTile.createComponent();
      }
      ++columnCount;
      if (columnCount == game.map.width) {
        columnCount = 0;
        ++lineCount;
      }
    });
    layerCount++;
  });

  // Read objectgroups
  mapXml.findElements('objectgroup').forEach((objectgroup) {
    objectgroup.findElements('object').forEach((object) {
      var isTileObject = (object.getAttribute('gid') != null);
      var tile = isTileObject
          ? _tileMap[int.parse(object.getAttribute('gid'))]
          : Tile();
      var x =
          int.parse(object.getAttributeNode('x').value) / 16 * componentSize;
      var y = (int.parse(object.getAttributeNode('y').value) / 16 -
              (isTileObject ? 1 : 0)) *
          componentSize;
      var properties = <String, dynamic>{};
      object
          .findElements('properties')
          .single
          .findElements('property')
          .forEach((property) {
        properties[property.getAttributeNode('name').value] =
            property.getAttributeNode('value')?.value ?? property.text;
      });
      tile.type ??= object.getAttribute('type');
      tile.position = Point(x, y);
      tile.properties.addAll(properties);
      // Add itemId value even if properties['itemId'] == null
      tile.properties['itemId'] = properties['itemId'];
      tile.id = int.parse(object.getAttribute('id'));
      tile.createComponent();
    });
  });
}
