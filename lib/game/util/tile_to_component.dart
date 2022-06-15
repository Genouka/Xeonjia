import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/slither_cpu.dart';
import 'package:xeonjia/game/components/dynamic/walker_cpu.dart';
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
  void createComponent() {
    switch (type) {
      case 'Solid':
        StaticComponent(this);
        break;
      case 'Modifier':
        properties['itemId'] ??= '${game.map.id}.$id';
        var itemId = properties['itemId'];

        // Load item only if it is not an unique item (id == "0")
        // or if it is not already owned by the player
        if (itemId == '0' || !mainCharacter.itemList.contains(itemId)) {
          ModifierComponent(this);
        }
        break;
      case 'Ground':
        StaticComponent(this, walkable: true);
        break;
      case 'Door':
        if (game.config.mode == GameMode.story) {
          var previousRoomId = (mainCharacter.visitedRooms.length <= 1)
              ? '0'
              : mainCharacter
                  .visitedRooms[mainCharacter.visitedRooms.length - 2];
          if (previousRoomId.split('/').first +
                  (mainCharacter.visitedRooms.last.contains('/')
                      ? '/' + mainCharacter.visitedRooms.last.split('/').last
                      : '') ==
              properties['roomId']) {
            properties['image'] = 'character.png';
            CharacterComponent(
                Tile()
                  ..id = -1
                  ..position = position
                  ..properties = properties,
                isPlayerOne: true,
                weaponList: mainCharacter.weaponList
                    .map((e) => Weapon.fromJson(e.toJson()))
                    .toList(),
                newSelectedWeaponIndex: mainCharacter.selectedWeaponIndex);
          }
          if (properties['roomId'] != '0') DoorComponent(this);
        } else {
          var teamId = int.parse(properties['team'] ?? '0');
          if (game.players.where((p) => p.teamId == teamId).length <
              game.config.teamSize) {
            var playerOne = game.playerOne == null && teamId == 0;
            properties['image'] =
                'character${playerOne ? '' : '_cpu_$teamId'}.png';
            properties['friendly'] = 'false';
            properties['quiet'] = 'false';
            properties['def'] = '4';
            CharacterComponent(
              this,
              isPlayerOne: playerOne,
              team: teamId,
              level: teamId * game.config.difficulty,
            );
          }
        }
        break;
      case 'ThinWall':
        ThinWallComponent(this);
        break;
      case 'NPC':
        CharacterComponent.npc(this);
        break;
      case 'Hurdle':
        HurdleComponent(this);
        break;
      case 'DirectionChanger':
        DirectionChangerComponent(this);
        break;
      case 'WalkerCpu':
        WalkerCpuComponent(this);
        break;
      case 'SlitherCpu':
        if (!(game.currentEventLog['${game.map.id}-safe'] ?? false)) {
          SlitherCpuComponent(this);
        }
        break;
      default:
        break;
    }
  }
}
