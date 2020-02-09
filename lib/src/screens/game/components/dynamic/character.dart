import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';
import 'package:xeonjia/src/screens/game/utils/weapon.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Dynamic component used for user controlled player
class CharacterComponent extends DynamicComponent {
  // List of weapon owned
  List<Weapon> weaponList = [];

  // Weapon selected from weaponList
  int _selectedWeaponElement = 0;

  // Money earned during match time
  int earnedMoney = 0;

  // List of door keys owned
  List<int> doorKeyList = [];

  // List of objects owned (eg gems)
  List<int> objectList = [];

  // Initial life points
  double initialLifePoints;

  CharacterComponent(tile) : super.fromTile(tile);

  CharacterComponent.main(tile)
      : initialLifePoints = (100 + 5 * mainCharacter.level).toDouble(),
        super(tile.x, tile.y,
            'character-${int.parse(tile.properties['orientation'] ?? '1')}.png') {
    orientation = int.parse(tile.properties['orientation'] ?? '1');
    atk = (mainCharacter.level + 1).toDouble();
    def = (mainCharacter.level ~/ 5).toDouble();
    doorKeyList = List.from(mainCharacter.doorKeyList);
    doorKeyList = List.from(mainCharacter.objectList);
    mainCharacter.jsonWeaponList.forEach((weaponId, weaponLevel) {
      switch (int.parse(weaponId)) {
        case 0:
          weaponList.add(PunchWeapon(level: weaponLevel));
          break;
        case 1:
          weaponList.add(SnowBallWeapon(level: weaponLevel));
          break;
        case 2:
          weaponList.add(MineWeapon(level: weaponLevel));
          break;
        default:
          break;
      }
    });
    player = this;
    game.updateCamera(x, y);
  }

  Weapon get selectedWeapon => weaponList[_selectedWeaponElement];

  // Select next weapon in weapon list
  void nextWeapon() {
    if (++_selectedWeaponElement >= weaponList.length) {
      _selectedWeaponElement = 0;
    }
  }

  @override
  void hasMoved() {
    if (this == player) game.updateCamera(x, y);
  }

  @override
  void componentDeleted() {
    super.componentDeleted();
    if (this == player) {
      if (game.mode == GameMode.story) game.end();
      // TODO: else...
    }
  }
}
