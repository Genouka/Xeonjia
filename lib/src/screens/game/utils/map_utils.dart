import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/character.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/slither_cpu.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/walker_cpu.dart';
import 'package:xeonjia/src/screens/game/components/static/basic_static.dart';
import 'package:xeonjia/src/screens/game/components/static/direction_changer.dart';
import 'package:xeonjia/src/screens/game/components/static/door.dart';
import 'package:xeonjia/src/screens/game/components/static/ground.dart';
import 'package:xeonjia/src/screens/game/components/static/hurdle.dart';
import 'package:xeonjia/src/screens/game/components/static/modifer.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';
import 'package:xeonjia/src/widgets/toast.dart';

// Map that stores each tile id and tile details
Map<int, Tile> _tileMap;

// Previous room visited by the player
int _previousRoomId;

// Text displayed entering in a room
String _toastText;

// Class used to manage a single tile
class Tile {
  // Tile ID defined in the TMX file
  int id;

  // Component type
  String type;

  // List of tile properties
  // Properties define component features and stats (eg: atk, def, lifePoints)
  Map<String, dynamic> properties = {};

  // Component image
  String image;

  // Component size
  double size = componentSize;

  // Start position
  double x;
  double y;

  Tile();
  Tile.fromValues(
      {this.id,
      this.type,
      this.properties,
      this.image,
      this.size,
      this.x,
      this.y});
}

// Import map and tileset details from a TMX file
importMap(String fileName) async {
  _tileMap = {};

  // Read TMX (xml) file
  String importedTmx = await rootBundle.loadString(fileName);
  var xmlElement = xml.parse(importedTmx).rootElement;

  // Get map information
  game.mapWidth = int.parse(xmlElement.getAttribute('width'));
  game.mapHeight = int.parse(xmlElement.getAttribute('height'));

  // Read map properties
  var mapProperties = xmlElement.findElements('properties');
  _toastText =
      'Room ${mainCharacter.visitedRooms.last.toString().padLeft(3, '0')}';
  if (mapProperties.isNotEmpty) {
    mapProperties.single.children.forEach((property) {
      if (property.attributes.isNotEmpty &&
          property.attributes[0].value == 'hint') {
        _toastText += ':\n' + property.attributes[1].value;
      }
    });
  }

  // Read tileSet
  var tileSet = xmlElement.findElements('tileset');

  // Get each tile details from tileset
  tileSet.single.findElements('tile').forEach((tile) {
    Tile newTile = Tile();
    newTile.id = int.parse(tile.getAttribute('id')) + 1;
    newTile.type = tile.getAttribute('type');
    newTile.image = tile.findElements('image').single.getAttribute('source');
    // Import tile properties
    var properties = tile.findElements('properties');
    if (properties.isNotEmpty) {
      properties.single.children.forEach((property) {
        if (property.attributes.isNotEmpty) {
          newTile.properties[property.attributes[0].value] =
              property.attributes[2].value;
        }
      });
    }
    // Store tile details in tileMap
    _tileMap[newTile.id] = newTile;
  });

  // Get id of the previously visited room
  _previousRoomId = (mainCharacter.visitedRooms.length <= 1)
      ? 1
      : mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2];

  parseMapTiles(xmlElement);
}

// Import map data from a TMX file
// It just import data managed in this game
void parseMapTiles(var xmlElement) {
  String mapData =
      xmlElement.findElements('layer').single.findElements('data').single.text;

  // Read map line by line
  List<String> lines = mapData.split('\n');
  int lineCount = 0;
  int columnCount = 0;
  lines.forEach((line) {
    List<String> tiles = line.split(',');
    // Parse map layer and create components based on "Type" tile property
    tiles.forEach((tileId) {
      if (tileId.isNotEmpty) {
        Tile componentTile = _tileMap[int.parse(tileId)];
        if (componentTile != null) {
          componentTile.x = componentSize * columnCount;
          componentTile.y = componentSize * lineCount;
          switch (componentTile?.type) {
            case 'Solid':
              BasicStaticComponent(componentTile);
              break;
            case 'Modifier':
              int _doorId = int.parse(componentTile.properties['door'] ?? '-1');
              int _objectId =
                  int.parse(componentTile.properties['objectId'] ?? '-1');
              // Import object only if it is not already owned by the player
              // or if it is not an unique object
              if ((_doorId == -1 ||
                      !mainCharacter.doorKeyList.contains(_doorId)) &&
                  (_objectId == -1 ||
                      !mainCharacter.objectList.contains(_objectId))) {
                ModifierComponent(componentTile);
              }
              break;
            case 'Ground':
              GroundComponent(componentTile);
              break;
            case 'Start':
              if (_previousRoomId ==
                  int.parse(componentTile.properties['roomId'])) {
                CharacterComponent.main(componentTile);
                Toast.show(_toastText, gameContext,
                    gravity: (lineCount < 5) ? 0 : 2);
              }
              break;
            case 'Door':
              DoorComponent(componentTile);
              break;
            case 'Hurdle':
              HurdleComponent(componentTile);
              break;
            case 'DirectionChanger':
              DirectionChangerComponent(componentTile);
              break;
            case 'WalkerCpu':
              WalkerCpuComponent(componentTile);
              break;
            case 'SlitherCpu':
              SlitherCpuComponent(componentTile);
              break;
            default:
              break;
          }
        }
        ++columnCount;
        if (columnCount == game.mapWidth) {
          columnCount = 0;
          ++lineCount;
        }
      }
    });
  });
}
