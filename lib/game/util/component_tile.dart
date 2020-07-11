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
        var _doorId = int.parse(properties['door'] ?? '-1');
        var _objectId = int.parse(properties['objectId'] ?? '-1');
        // Import object only if it is not already owned by the player
        // or if it is not an unique object
        if ((_doorId == -1 || !mainCharacter.doorKeyList.contains(_doorId)) &&
            (_objectId == -1 ||
                !mainCharacter.objectList.contains(_objectId))) {
          ModifierComponent(this);
        }
        break;
      case 'Ground':
        GroundComponent(this);
        break;
      case 'Start':
        // Id of the previously visited room
        var _previousRoomId = (mainCharacter.visitedRooms.length <= 1)
            ? 1
            : mainCharacter.visitedRooms[mainCharacter.visitedRooms.length - 2];
        if (game.config.mode == GameMode.story &&
            _previousRoomId == int.parse(properties['roomId'])) {
          CharacterComponent(this,
              isPlayerOne: true,
              level: mainCharacter.level,
              jsonWeaponList: mainCharacter.jsonWeaponList);
          // Toast.show(_toastText, gameContext, gravity: (lineCount < 5) ? 0 : 2);
        } else if (game.config.mode == GameMode.tdm) {
          var _teamId = int.parse(properties['team'] ?? '0');
          if (game.players.where((p) => p.teamId == _teamId).length <
              game.config.teamSize) {
            CharacterComponent(
              this,
              isPlayerOne: playerOne == null && _teamId == 0,
              team: _teamId,
              level: _teamId * game.config.difficulty,
            );
          }
        }
        break;
      case 'Door':
        DoorComponent(this);
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
