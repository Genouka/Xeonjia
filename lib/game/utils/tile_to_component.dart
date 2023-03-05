import 'package:xeonjia/game/xeonjia.dart';

extension CreateComponent on Tile {
  /// Create components based on tile property "type"
  void createComponent(XeonjiaGame gameRef) {
    switch (tiledClass) {
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
          if (properties['isPlayerOne'] == true) {
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
          if (properties['roomId'] != '0' &&
              properties['createDoor'] != false) {
            gameRef.add(DoorComponent(this));
          }
        } else {
          var teamId = int.parse(properties['team'] ?? '0');
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
      case 'SliderCpu':
        if (!(gameRef.currentEventLog['${gameRef.map.id}-safe'] ?? false)) {
          gameRef.add(SliderCpuComponent(this));
        }
        break;
      default:
        break;
    }
  }
}
