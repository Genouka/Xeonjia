import 'dart:math';
import 'dart:ui';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/game/util/respawn_animation.dart';
import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/tile.dart';

// Dynamic component used for human-like players
class CharacterComponent extends DynamicComponent
    with LifePointsBar, RespawnAnimation {
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

  // Initial orientation
  Direction _initialOrientation;

  // NPC features: If friendly it doesn't shoot. If quiet it doesn't move.
  bool friendly;
  bool quiet;

  @override
  double initialLifePoints;

  @override
  bool isSolid({DynamicComponent otherComponent}) => !isRespawning;

  // Create character from input details
  CharacterComponent(
    Tile tile, {
    bool isPlayerOne = false,
    int level = 0,
    double initialLP,
    Map<String, dynamic> jsonWeaponList,
    team = 0,
  })  : initialLifePoints = initialLP ?? (100 + 5 * level).toDouble(),
        super(
            tile.position, 'character${isPlayerOne ? '' : '_cpu_$team'}.png') {
    orientation =
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0'));
    _initialOrientation = orientation;
    friendly = 'true' == tile.properties['friendly'] ?? 'false';
    quiet = 'true' == tile.properties['quiet'] ?? 'false';
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

  // Non-Player Character
  CharacterComponent.npc(Tile tile) : this(tile, initialLP: double.infinity);

  Weapon get selectedWeapon => weaponList[_selectedWeaponElement];
  void shoot([Weapon weapon]) {
    if (isRespawning) return;
    (weapon ?? selectedWeapon).shoot(shooter: this);
  }

  // Select next weapon in weapon list
  void nextWeapon() {
    if (++_selectedWeaponElement >= weaponList.length) {
      _selectedWeaponElement = 0;
    }
  }

  // Inspect what is in front of this
  void inspect() {
    if (isRespawning) return;
    game.message = componentInFront()?.message;
  }

  @override
  void hasMoved() {
    if (this == playerOne) game.updateCamera(x, y);
  }

  @override
  void delete() {
    ++deaths;
    if (game.config.mode == GameMode.story) {
      super.delete();
      if (this == playerOne) game.end();
    } else {
      stop();
      respawnAnimation();
      game.checkMatchStatus();
    }
  }

  // Respawn player
  void respawn() {
    restoreLifePoints();
    removeChildren();
    weaponList.forEach((weapon) {
      weapon.resetPp();
    });
    _selectedWeaponElement = 0;
    movesCounter = 0;
    isRespawning = false;
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
      if (!quiet) _cpuMove();
      if (!friendly) _cpuShoot();
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

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, -componentSize / 8));
  }
}
