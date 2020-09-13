import 'dart:math';
import 'dart:ui';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/game/util/respawn_animation.dart';
import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/models/tile.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Dynamic component used for human-like players
class CharacterComponent extends DynamicComponent
    with LifePointsBar, RespawnAnimation {
  @override
  bool get isPlayerOne => this == game?.playerOne;

  // List of weapon owned
  List<Weapon> weaponList = [];

  // Weapon selected from weaponList
  int _selectedWeaponElement = 0;

  // Money earned during match time
  int _earnedMoney = 0;
  int get earnedMoney => _earnedMoney;
  set earnedMoney(int moneyDelta) {
    if (moneyDelta == 0) return;
    _earnedMoney += moneyDelta;
    showText('+ $moneyDelta ¤');
  }

  // Money available
  int get money => _earnedMoney + mainCharacter.money;

  // List of items owned
  // Add/remove items by using addItem() and removeItem()
  List<int> _itemList = [];
  List<int> get itemList => _itemList;

  // Initial orientation
  Direction _initialOrientation;

  // NPC features: If friendly it doesn't shoot. If quiet it doesn't move.
  bool friendly;
  bool quiet;

  @override
  double initialLifePoints;

  @override
  bool isSolid({DynamicComponent otherComponent}) => !isBeingDeleted;

  @override
  void playAction(Direction orientation) {
    this.orientation = orientation.opposite;
    super.playAction(orientation);
  }

  // Create character from input details
  CharacterComponent(
    Tile tile, {
    bool isPlayerOne = false,
    int level = 0,
    double initialLP,
    Map<String, dynamic> jsonWeaponList,
    team = 0,
  })  : initialLifePoints = initialLP ??
            ((isPlayerOne && game.config.mode == GameMode.story)
                ? mainCharacter.lifePoints
                : (100 + 5 * level).toDouble()),
        super(tile.position, tile.properties['image'],
            imageY: tile.properties['imageY'] ?? 0) {
    orientation =
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0'));
    _initialOrientation = orientation;
    friendly = 'true' == (tile.properties['friendly'] ?? 'true');
    quiet = 'true' == (tile.properties['quiet'] ?? 'true');
    atk = (isPlayerOne && game.config.mode == GameMode.story)
        ? mainCharacter.atk
        : (level + 1).toDouble();
    def = (isPlayerOne && game.config.mode == GameMode.story)
        ? mainCharacter.def
        : (level ~/ 5).toDouble();
    teamId = team;
    actionOnEvent = tile.properties['actionOnEvent'] ?? '';
    action = tile.properties['action'] ?? '';
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
      game.playerOne = this;
      status(
          mainCharacter.currentLifePoints <= 0
              ? initialLifePoints
              : mainCharacter.currentLifePoints,
          mainCharacter.poisonQuantity);
      game.refreshWeaponBar();
      game.refreshLifePointsBar();
      game.updateCamera(x, y);
      if (game.config.mode == GameMode.story) {
        _itemList = List.from(mainCharacter.itemList);
      }
    }
    executeAction();
  }

  // Non-Player Character (story mode)
  CharacterComponent.npc(Tile tile) : this(tile, initialLP: double.infinity);

  Weapon get selectedWeapon => weaponList[_selectedWeaponElement];
  void shoot([Weapon weapon]) {
    if (isBeingDeleted) return;
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
    if (isStationary && !isBeingDeleted) {
      componentInFront()?.playAction(orientation);
    }
  }

  // Add item to _itemList
  void addItem(int itemId) {
    _itemList.add(itemId);
    if (isPlayerOne) {
      if (itemData.containsKey(itemId)) {
        game.setMessage(Message('* You received ${itemData[itemId].name} *'));
      }
      game.playSound(Sfx.item);
    }
  }

  // Remove item from _itemList
  void removeItem(int itemId) {
    _itemList.remove(itemId);
    if (isPlayerOne) {
      game.setMessage(Message('* You gave ${itemData[itemId].name} *'));
    }
  }

  @override
  void hasMoved() {
    if (isPlayerOne) {
      game.updateCamera(x, y);
    }
  }

  @override
  void delete() {
    ++deaths;
    if (game.config.mode == GameMode.story) {
      super.delete();
      if (isPlayerOne) game.end();
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
    isBeingDeleted = false;
    x = startingPosition.x;
    y = startingPosition.y;
    orientation = _initialOrientation;
    if (isPlayerOne) {
      game.refreshWeaponBar();
      game.updateCamera(x, y);
    }
  }

  @override
  void update(double t) {
    if (!isPlayerOne) {
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
