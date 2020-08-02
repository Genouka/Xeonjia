import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/dynamic/slither_cpu.dart';
import 'package:xeonjia/game/components/dynamic/walker_cpu.dart';
import 'package:xeonjia/game/components/static/basic_static.dart';
import 'package:xeonjia/game/components/static/direction_changer.dart';
import 'package:xeonjia/game/components/static/door.dart';
import 'package:xeonjia/game/components/static/ground.dart';
import 'package:xeonjia/game/components/static/hurdle.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/tile.dart';
import 'package:xeonjia/util/local_data_controller.dart';

extension CreateComponent on Tile {
  // Create components based on tile property "type"
  void createComponent() {
    switch (type) {
      case 'Solid':
        BasicStaticComponent(this);
        break;
      case 'Modifier':
        var _itemId = int.parse(properties['itemId'] ?? '-1');
        // Import item only if it is not already owned by the player
        // or if it is not an unique item
        if (_itemId == -1 || !mainCharacter.itemList.contains(_itemId)) {
          ModifierComponent(this);
        }
        break;
      case 'Ground':
        GroundComponent(this);
        break;
      case 'Door':
        if (game.config.mode == GameMode.story) {
          var _previousRoomId = (mainCharacter.visitedRooms.length <= 1)
              ? 1
              : mainCharacter
                  .visitedRooms[mainCharacter.visitedRooms.length - 2];
          if (_previousRoomId == int.parse(properties['roomId'])) {
            properties['image'] = 'character.png';
            CharacterComponent(this,
                isPlayerOne: true,
                level: mainCharacter.level,
                jsonWeaponList: mainCharacter.jsonWeaponList);
          }
          if (_previousRoomId != 0) DoorComponent(this);
        } else {
          var _teamId = int.parse(properties['team'] ?? '0');
          if (game.players.where((p) => p.teamId == _teamId).length <
              game.config.teamSize) {
            var _playerOne = game.playerOne == null && _teamId == 0;
            properties['image'] =
                'character${_playerOne ? '' : '_cpu_$_teamId'}.png';
            CharacterComponent(
              this,
              isPlayerOne: _playerOne,
              team: _teamId,
              level: _teamId * game.config.difficulty,
            );
          }
        }
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
        SlitherCpuComponent(this);
        break;
      default:
        break;
    }
  }
}
