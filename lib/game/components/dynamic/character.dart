import 'dart:math';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/tile.dart';

// Dynamic component used for human-like players
class CharacterComponent extends DynamicComponent with LifePointsBar {
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

  @override
  double initialLifePoints;

  // Initial orientation
  Direction _initialOrientation;

  // Create character from input details
  CharacterComponent(
    Tile tile, {
    bool isPlayerOne = false,
    int level = 0,
    Map<String, dynamic> jsonWeaponList,
    team = 0,
  })  : initialLifePoints = (100 + 5 * level).toDouble(),
        super(
            tile.position, 'character${isPlayerOne ? '' : '_cpu_$team'}.png') {
    orientation =
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0'));
    _initialOrientation = orientation;
    atk = (level + 1).toDouble();
    def = (level ~/ 5).toDouble();
    teamId = team;
    // Temporary solution to remedy the functions _cpuMove() and _cpuShoot()
    jsonWeaponList ??=
        (team == 0) ? const {'1': 5, '2': 1} : const {'1': 9, '2': 5};
    jsonWeaponList.forEach((weaponId, weaponLevel) {
      switch (int.parse(weaponId)) {
        case 0:
          weaponList.add(PunchWeapon(level: atk.round()));
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
  void shoot([Weapon weapon]) {
    (weapon ?? selectedWeapon).shoot(shooter: this);
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
    if (game.config.mode == GameMode.story) {
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
    x = startingPosition.x;
    y = startingPosition.y;
    orientation = _initialOrientation;
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
      updateDirection(_initialOrientation);
    } else if (isStationary) {
      if (randomDouble() > 0.4) updateDirection(GetDirection.random);
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
