import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/game/utils/weapon.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Dynamic component used for human-like players
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

  // Create character from input details
  CharacterComponent(
    tile, {
    bool isPlayerOne = false,
    int level = 0,
    Map<String, dynamic> jsonWeaponList = const {'0': 0, '1': 0},
    team = 0,
  })  : initialLifePoints = (100 + 5 * level).toDouble(),
        super(tile.x, tile.y,
            'character-${int.parse(tile.properties['orientation'] ?? '1')}.png') {
    orientation = int.parse(tile.properties['orientation'] ?? '1');
    atk = (level + 1).toDouble();
    def = (level ~/ 5).toDouble();
    this.team = team;
    jsonWeaponList.forEach((weaponId, weaponLevel) {
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
    game.players.add(this);
    if (isPlayerOne) {
      playerOne = this;
      game.updateCamera(x, y);
    }
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
    if (this == playerOne) game.updateCamera(x, y);
  }

  @override
  void delete() {
    ++deaths;
    if (game.mode == GameMode.story) {
      if (this == playerOne) {
        super.delete();
        game.end();
      } else {
        super.delete();
      }
    } else {
      respawn();
    }
  }

  // Respawn player
  void respawn() {
    stop();
    restoreLifePoints();
    weaponList.forEach((weapon) {
      weapon.resetPp();
    });
    _selectedWeaponElement = 0;
    x = startX;
    y = startY;
    if (this == playerOne) {
      weaponBar.state.refresh(percent: 1, text: 'Punch');
      game.updateCamera(x, y);
    }
  }
}
