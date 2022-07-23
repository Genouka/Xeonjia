import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/slither_cpu.dart';
import 'package:xeonjia/game/components/static/direction_changer.dart';
import 'package:xeonjia/game/components/static/door.dart';
import 'package:xeonjia/game/components/static/hurdle.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/components/static/static.dart';
import 'package:xeonjia/game/components/static/thin_wall.dart';
import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/tile.dart';
import 'package:xeonjia/util/local_data_controller.dart';

extension CreateComponent on Tile {
  // Create components based on tile property "type"
  void createComponent(XeonjiaGame gameRef) {
    switch (type) {
      case 'Solid':
        gameRef.add(StaticComponent(this));
        break;
      case 'Modifier':
        properties['itemId'] ??= '${gameRef.map.id}.$id';
        var itemId = properties['itemId'];

        // Load item only if it is not an unique item (id == "0")
        // or if it is not already owned by the player
        if (itemId == '0' || !mainCharacter.itemList.contains(itemId)) {
          gameRef.add(ModifierComponent(this));
        }
        break;
      case 'Ground':
        gameRef.add(StaticComponent(this, walkable: true));
        break;
      case 'Door':
        if (gameRef.config.mode == GameMode.story) {
          var previousRoomId = (mainCharacter.visitedRooms.length <= 1)
              ? '0'
              : mainCharacter
                  .visitedRooms[mainCharacter.visitedRooms.length - 2];
          if (previousRoomId.split('/').first +
                  (mainCharacter.visitedRooms.last.contains('/')
                      ? '/' + mainCharacter.visitedRooms.last.split('/').last
                      : '') ==
              properties['roomId']) {
            properties['isPlayerOne'] = true;
            gameRef.add(CharacterComponent(
                Tile()
                  ..id = -1
                  ..position = position
                  ..properties = properties,
                gameRef.config,
                inputWeaponList: mainCharacter.weaponList
                    .map((e) => Weapon.fromJson(e.toJson()))
                    .toList(),
                newSelectedWeaponIndex: mainCharacter.selectedWeaponIndex));
          }
          if (properties['roomId'] != '0') gameRef.add(DoorComponent(this));
        } else {
          var teamId = int.parse(properties['team'] ?? '0');
          //print(gameRef.players.length);
          if (gameRef.players.where((p) => p.teamId == teamId).length <
              gameRef.config.teamSize) {
            var playerOne = gameRef.playerOne == null && teamId == 0;
            properties['friendly'] = 'false';
            properties['quiet'] = 'false';
            properties['def'] = '4';
            properties['isPlayerOne'] = playerOne;
            gameRef.add(CharacterComponent(
              this,
              gameRef.config,
              team: teamId,
              level: teamId * gameRef.config.difficulty,
            ));
          }
        }
        break;
      case 'ThinWall':
        gameRef.add(ThinWallComponent(this));
        break;
      case 'NPC':
        gameRef.add(CharacterComponent.npc(this, gameRef.config));
        break;
      case 'Hurdle':
        gameRef.add(HurdleComponent(this));
        break;
      case 'DirectionChanger':
        gameRef.add(DirectionChangerComponent(this));
        break;
      case 'SlitherCpu':
        if (!(gameRef.currentEventLog['${gameRef.map.id}-safe'] ?? false)) {
          gameRef.add(SlitherCpuComponent(this));
        }
        break;
      default:
        break;
    }
  }
}
