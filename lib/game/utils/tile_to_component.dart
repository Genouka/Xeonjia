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
        if (properties['isPlayerOne'] == true) {
          gameRef.add(CharacterComponent(
              Tile()
                ..id = -1
                ..position = position
                ..properties = properties,
              inputWeaponList: mainCharacter.weaponList
                  .map((e) => Weapon.fromJson(e.toJson()))
                  .toList(),
              newSelectedWeaponIndex: mainCharacter.selectedWeaponIndex));
        }
        if (properties['roomId'] != '0' && properties['createDoor'] != false) {
          gameRef.add(DoorComponent(this));
        }
        break;
      case 'ThinWall':
        gameRef.add(ThinWallComponent(this));
        break;
      case 'NPC':
        gameRef.add(CharacterComponent.npc(this));
        break;
      case 'Hurdle':
        gameRef.add(HurdleComponent(this));
        break;
      case 'DirectionChanger':
        gameRef.add(DirectionChangerComponent(this));
        break;
      case 'Monster':
        if (!(gameRef.currentEventLog['${gameRef.map.id}-safe'] ?? false)) {
          gameRef.add(MonsterComponent(this));
        }
        break;
      default:
        break;
    }
  }
}
