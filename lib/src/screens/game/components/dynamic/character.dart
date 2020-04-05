import 'dart:math';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/components/abstract_dynamic.dart';
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

  // Initial orientation
  int _initialOrientation;

  // Create character from input details
  CharacterComponent(
    tile, {
    bool isPlayerOne = false,
    int level = 0,
    Map<String, dynamic> jsonWeaponList,
    team = 0,
  })  : initialLifePoints = (100 + 5 * level).toDouble(),
        super(
            tile.x,
            tile.y,
            (isPlayerOne ? '' : ('cpu${team}_')) +
                'character-${int.parse(tile.properties['orientation'] ?? '1')}.png') {
    orientation = int.parse(tile.properties['orientation'] ?? '1');
    _initialOrientation = orientation;
    atk = (level + 1).toDouble();
    def = (level ~/ 5).toDouble();
    teamId = team;
    if (jsonWeaponList == null) {
      // Temporary solution to remedy the functions _cpuMove() and _cpuShoot()
      jsonWeaponList =
          (team == 0) ? const {'1': 5, '2': 1} : const {'1': 9, '2': 5};
    }
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
      game.refreshWeaponBar();
      game.refreshLifePointsBar();
      game.updateCamera(x, y);
    }
  }

  Weapon get selectedWeapon => weaponList[_selectedWeaponElement];
  void shoot() {
    selectedWeapon.shoot(shooter: this);
  }

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
    removeChildren();
    weaponList.forEach((weapon) {
      weapon.resetPp();
    });
    _selectedWeaponElement = 0;
    movesCounter = 0;
    x = startX;
    y = startY;
    orientation = _initialOrientation;
    updateSprite();
    if (this == playerOne) {
      game.refreshWeaponBar();
      game.updateCamera(x, y);
    }
  }

  @override
  void update(double t) {
    if (this != playerOne) {
      _cpuMove();
      _cpuShoot();
    }
    super.update(t);
  }

  // Move done if this is controlled by CPU
  void _cpuMove() {
    if (movesCounter == 0) {
      List<double> _firstMove = directionToXY(_initialOrientation);
      updateDirection(_firstMove.first, _firstMove.last);
    } else if (isStationary) {
      if (randomDouble() > 0.4) {
        if (randomDouble() > 0) {
          updateDirection(randomDouble(), 0);
        } else {
          updateDirection(0, randomDouble());
        }
      }
    }
  }

  // Shot done if this is controlled by CPU
  void _cpuShoot() {
    if (Random().nextDouble() > 0.98) {
      if (Random().nextDouble() > 0.6) nextWeapon();
      shoot();
    }
  }
}
