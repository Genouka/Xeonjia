import 'dart:ui';

import 'package:xeonjia/i18n/ui.i18n.dart';
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

  // Index of the weapon selected from weaponList
  int selectedWeaponIndex;

  // Money earned by the player
  int _money = mainCharacter.money;
  int get money => _money;
  void moneyDifference(int moneyDelta, {bool popup = true}) {
    if (moneyDelta == 0) return;
    _money += moneyDelta;
    if (popup) showText('+ $moneyDelta ¤');
  }

  // Total number of minutes played by the character in this game
  double get minutesPlayed =>
      mainCharacter.minutesPlayed + game.elapsedSeconds / 60;

  // List of items owned
  // Add/remove items by using addItem() and removeItem()
  List<String> _itemList = [];
  List<String> get itemList => _itemList;

  // Initial orientation
  Direction _initialOrientation;

  // NPC features: If friendly it doesn't shoot. If quiet it doesn't move.
  bool friendly;
  bool quiet;
  final double _updatePeriod = 0.1;
  double _timeToNextMove = 0.1;
  final double _shootPeriod = 0.2;
  double _timeToNextShoot = 0.2;

  @override
  double maxLifePoints;

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
    this.weaponList,
    int newSelectedWeaponIndex = 0,
    team = 0,
  })  : maxLifePoints = initialLP ??
            ((isPlayerOne && game.config.mode == GameMode.story)
                ? mainCharacter.maxLifePoints
                : (100 + 5 * level).toDouble()),
        super(tile.position, tile.properties) {
    orientation =
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0'));
    _initialOrientation = orientation;
    friendly = 'true' == (tile.properties['friendly'] ?? 'true');
    quiet = 'true' == (tile.properties['quiet'] ?? 'true');
    if (isPlayerOne && game.config.mode == GameMode.story) {
      atk = mainCharacter.atk;
      def = mainCharacter.def;
    } else {
      atk = (level + 1).toDouble();
      def = (def != 0 ? def : (level ~/ 5).toDouble());
      if (isPlayerOne) {
        weaponList = [
          PunchWeapon(level: 10),
          SnowBallWeapon(level: 5),
          MineWeapon(level: 3),
        ];
        selectedWeaponIndex = 1;
      }
    }
    teamId = team;
    weaponList ??= (team == 0)
        ? [SnowBallWeapon(level: 5), MineWeapon(level: 1)]
        : [SnowBallWeapon(level: 9), MineWeapon(level: 5)];
    selectedWeaponIndex ??= newSelectedWeaponIndex;
    game.players.add(this);
    if (isPlayerOne) {
      game.playerOne = this;
      setStatus(
          mainCharacter.currentLifePoints <= 0 ||
                  game.config.mode != GameMode.story
              ? maxLifePoints
              : mainCharacter.currentLifePoints,
          mainCharacter.poisonQuantity);
      game.refreshWeaponButtons();
      game.refreshLifePointsBar();
      game.updateCamera(x, y);
      if (game.config.mode == GameMode.story) {
        _itemList = List.from(mainCharacter.itemList);
      }
      game.executeAction(action: game.map.action, actor: game.playerOne);
    }
    if (game.config.mode != GameMode.story) {
      isPlayerOne
          ? updateOrientation(_initialOrientation)
          : updateDirection(_initialOrientation);
    }
  }

  // Non-Player Character (story mode)
  CharacterComponent.npc(Tile tile) : this(tile, initialLP: double.infinity);

  // Weapon
  Weapon get selectedWeapon => weaponList[selectedWeaponIndex];
  void shoot() {
    if (isBeingDeleted || game.isPaused) return;
    selectedWeapon.shoot(shooter: this);
  }

  // Shoot with the weapon that has weapon.id == id
  void shootById(int id) {
    var newWeaponIndex = weaponList.indexWhere((weapon) => weapon.id == id);
    if (weaponList[newWeaponIndex].powerPoints > 0) {
      selectedWeaponIndex = newWeaponIndex;
      shoot();
    }
  }

  // True if this has the weapon
  bool hasWeaponId(int id) =>
      weaponList.where((weapon) => weapon.id == id).isNotEmpty;

  // Return the weapon object by passing the id
  Weapon getWeaponById(int id) =>
      weaponList.firstWhere((weapon) => weapon.id == id);

  // Select next weapon in weapon list
  void nextWeapon() {
    if (++selectedWeaponIndex >= weaponList.length) selectedWeaponIndex = 0;
  }

  // Inspect what is in front of this
  void inspect() {
    if (game.isNotPaused && isStationary && !isBeingDeleted) {
      componentInFront()?.playAction(orientation);
    }
  }

  // Add item to _itemList
  void addItem(String itemId) {
    _itemList.add(itemId);
    if (isPlayerOne) {
      if (itemData.containsKey(itemId)) {
        game.setMessage(Message('* {{hero}} puts %s in the backpack. *'
            .i18n
            .fill([itemData[itemId].name])));
      } else if (itemId.contains('gem_')) {
        game.setMessage(
            Message('* {{hero}} puts the gem in the backpack. *'.i18n));
      }
      game.playSound(Sfx.item);
    }
  }

  // Remove item from _itemList
  void removeItem(int itemId) {
    _itemList.remove(itemId);
    if (isPlayerOne) {
      game.setMessage(
          Message('* {{hero}} gives %s *'.i18n.fill([itemData[itemId].name])));
    }
  }

  @override
  void hasMoved() {
    if (isPlayerOne) game.updateCamera(x, y);
  }

  @override
  void collidedBy(DynamicComponent componentAbove) {
    if (!isPlayerOne) super.collidedBy(componentAbove);
  }

  @override
  void delete() {
    ++defeats;
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
      weapon.restorePp();
    });
    movesCounter = 0;
    isBeingDeleted = false;
    x = startingPosition.x;
    y = startingPosition.y;
    orientation = _initialOrientation;
    if (isPlayerOne) {
      game.refreshWeaponButtons();
      game.updateCamera(x, y);
    }
  }

  @override
  void update(double t) {
    if (!isPlayerOne && game.isNotPaused) {
      if (!friendly && (_timeToNextShoot -= t) < 0) {
        if (randomDouble() > 0.1) nextWeapon();
        if (randomDouble() > 0.1) shoot();
        _timeToNextShoot = _shootPeriod;
      }

      if (!quiet && (_timeToNextMove -= t) < 0) {
        if (randomDouble() > 0.2) updateDirection(GetDirection.random);
        _timeToNextMove = _updatePeriod;
      }
    }
    super.update(t);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, characterOffset));
  }
}
