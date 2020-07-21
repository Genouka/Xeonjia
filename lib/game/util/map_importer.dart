import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/models/map_properties.dart';
import 'package:xml/xml.dart';

import 'package:xeonjia/game/util/component_tile.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/tile.dart';

// Import map from a TMX file
void importMap(String fileName) async {
  var mapXml =
      XmlDocument.parse(await rootBundle.loadString(fileName)).rootElement;

  // Get map information
  game.map = MapProperties(
    width: int.parse(mapXml.getAttribute('width')),
    height: int.parse(mapXml.getAttribute('height')),
  );

  var mapProperties = mapXml.findElements('properties');
  // 'Room ${mainCharacter.visitedRooms.last.toString().padLeft(3, '0')}';
  if (mapProperties.isNotEmpty) {
    mapProperties.single.children.forEach((property) {
      if (property.attributes.isNotEmpty &&
          property.attributes[0].value == 'message') {
        game.map.message = property.attributes[1].value;
      }
    });
  }

  // tileId : Tile
  var _tileMap = <int, Tile>{};

  // Read tileset
  await Future.forEach(mapXml.findElements('tileset'), (tilesetElement) async {
    var firstGid = int.parse(tilesetElement.getAttribute('firstgid'));

    XmlElement tileset = (tilesetElement.getAttribute('source') == null)
        ? tilesetElement
        : XmlDocument.parse(await rootBundle.loadString('assets/maps/' +
                tilesetElement.getAttribute('source').split('/').last))
            .rootElement;

    var tileWidth = double.parse(tileset.getAttribute('tilewidth'));
    var tileHeight = double.parse(tileset.getAttribute('tileheight'));
    var columns = int.parse(tileset.getAttribute('columns'));

    // Get tiles from tileset
    tileset.findElements('tile').forEach((tile) {
      var newTile = Tile(
        id: int.parse(tile.getAttribute('id')) + firstGid,
        type: tile.getAttribute('type'),
      );
      newTile.sprite = Sprite(
        tileset
            .findElements('image')
            .single
            .getAttribute('source')
            .split('../../images/')
            .last,
        x: ((newTile.id - firstGid) % columns) * tileWidth,
        y: ((newTile.id - firstGid) / columns).floor() * tileHeight,
        width: tileWidth,
        height: tileHeight,
      );

      // Read tile properties
      var properties = tile.findElements('properties');
      if (properties.isNotEmpty) {
        properties.single.children.forEach((property) {
          if (property.attributes.isNotEmpty) {
            newTile.properties[property.getAttributeNode('name').value] =
                property.getAttributeNode('value').value;
          }
        });
      }
      _tileMap[newTile.id] = newTile;
    });
  });

  mapXml.findElements('layer').forEach((layer) {
    var mapData = <int>[];
    var gzipMapData = layer.findElements('data').single.text;
    var m = gzip.decode(base64.decode(gzipMapData.trim()));
    for (var i = 0; i < m.length; i += 4) {
      mapData.add(m[i] + (m[i + 1] << 8) + (m[i + 2] << 16) + (m[i + 3] << 16));
    }

    var lineCount = 0;
    var columnCount = 0;
    mapData.forEach((tileId) {
      var componentTile = _tileMap[tileId];
      if (componentTile != null) {
        componentTile.position = Point(
            componentTile.size * columnCount, componentTile.size * lineCount);
        componentTile.createComponent();
      }
      ++columnCount;
      if (columnCount == game.map.width) {
        columnCount = 0;
        ++lineCount;
      }
    });
  });

  // Read groups
  mapXml.findElements('group').forEach((group) {
    if (group.getAttributeNode('name').value == 'Spawn points') {
      group.findElements('objectgroup').forEach((objectgroup) {
        objectgroup.findElements('object').forEach((object) {
          var x = int.parse(object.getAttributeNode('x').value) *
              componentSize /
              16;
          var y = int.parse(object.getAttributeNode('y').value) *
              componentSize /
              16;
          var properties = <String, dynamic>{};
          object
              .findElements('properties')
              .single
              .findElements('property')
              .forEach((property) {
            properties[property.getAttributeNode('name').value] =
                property.getAttributeNode('value').value;
          });
          Tile(
                  type: object.getAttribute('type'),
                  position: Point(x, y),
                  properties: properties)
              .createComponent();
        });
      });
    }
  });
}
