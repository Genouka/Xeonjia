import 'package:xeonjia/game/xeonjia.dart';

extension CreateComponent on Tile {
  /// Create components based on tile property "type"
  void createComponent(XeonjiaGame game) {
    switch (tiledClass) {
      case 'Solid':
        game.addComponent(StaticComponent(this));
        break;
      case 'Modifier':
        properties['itemId'] ??= '${game.map.id}.$id';
        var itemId = properties['itemId'];

        // Load item only if it is not an unique item (id == "0")
        // or if it is not already owned by the player
        if (itemId == '0' || !mainCharacter.itemList.contains(itemId)) {
          game.addComponent(ModifierComponent(this));
        }
        break;
      case 'Ground':
        game.addComponent(StaticComponent(this, walkable: true));
        break;
      case 'Door':
        if (properties['isPlayerOne'] == true) {
          game.addComponent(
            CharacterComponent(
              Tile()
                ..id = -1
                ..position = position
                ..properties = properties,
              inputWeaponList: mainCharacter.weaponList
                  .map((e) => Weapon.fromJson(e.toJson()))
                  .toList(),
            ),
          );
        }
        if (properties['roomId'] != '0' && properties['createDoor'] != false) {
          game.addComponent(DoorComponent(this));
        }
        break;
      case 'ThinWall':
        game.addComponent(ThinWallComponent(this));
        break;
      case 'NPC':
        game.addComponent(CharacterComponent.npc(this));
        break;
      case 'Hurdle':
        game.addComponent(HurdleComponent(this));
        break;
      case 'DirectionChanger':
        game.addComponent(DirectionChangerComponent(this));
        break;
      case 'Monster':
        if (!(game.currentEventLog['${game.map.id}-safe'] ?? false)) {
          game.addComponent(MonsterComponent(this));
        }
        break;
      default:
        break;
    }
  }
}
