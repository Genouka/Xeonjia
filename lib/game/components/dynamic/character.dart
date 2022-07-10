import 'dart:ui';

import 'package:xeonjia/game/components/abstract_dynamic.dart';
import 'package:xeonjia/game/util/lifepoints_bar.dart';
import 'package:xeonjia/game/util/npc_controller.dart';
import 'package:xeonjia/game/util/respawn_animation.dart';
import 'package:xeonjia/game/util/weapon.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/item.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/models/tile.dart';
import 'package:xeonjia/util/i18n.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Dynamic component used for human-like players
class CharacterComponent extends DynamicComponent
    with LifePointsBar, RespawnAnimation {
  // Create character from input details
  CharacterComponent(
    this.tile,
    MatchConfig matchConfig, {
    int level = 0,
    double? initialLP,
    List<Weapon>? inputWeaponList,
    int newSelectedWeaponIndex = 0,
    team = 0,
  }) : super(tile.id, tile.position!, tile.properties) {
    bool isPlayerOne = tile.properties['isPlayerOne'] ?? false;
    maxLifePoints = initialLP ??
        ((isPlayerOne && matchConfig.mode == GameMode.story)
            ? mainCharacter.maxLifePoints
            : (100 + 5 * level).toDouble());
    orientation =
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0'));
    _initialOrientation = orientation;
    friendly = 'true' == (tile.properties['friendly'] ?? 'true');
    quiet = 'true' == (tile.properties['quiet'] ?? 'true');
    if (isPlayerOne && matchConfig.mode == GameMode.story) {
      atk = mainCharacter.atk;
      def = mainCharacter.def;
    } else {
      atk = (level + 1).toDouble();
      def = def != 0 ? def : (level ~/ 5).toDouble();
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
    if (weaponList.isEmpty) {
      weaponList = inputWeaponList ??
          ((team == 0)
              ? [SnowBallWeapon(level: 5), MineWeapon(level: 1)]
              : [SnowBallWeapon(level: 9), MineWeapon(level: 5)]);
    }
    if (!isPlayerOne) selectedWeaponIndex = newSelectedWeaponIndex;
  }

  // Non-Player Character (story mode)
  CharacterComponent.npc(Tile tile, MatchConfig matchConfig)
      : this(
          tile,
          matchConfig,
          initialLP: double.parse(tile.properties['lp'] ?? 'Infinity'),
          team: int.parse(tile.properties['team'] ?? '0'),
          inputWeaponList: [
            SnowBallWeapon(
                level: int.parse(tile.properties['weaponLevel'] ?? '0'),
                powerPoints: double.infinity)
          ],
          level: int.parse(tile.properties['level'] ?? '0'),
        );

  @override
  Future<void>? onLoad() {
    super.onLoad();
    if (tile.properties['isPlayerOne'] ?? false) {
      setStatus(
          mainCharacter.currentLifePoints <= 0 ||
                  gameRef.config.mode != GameMode.story
              ? maxLifePoints
              : mainCharacter.currentLifePoints,
          mainCharacter.poisonQuantity);
      gameRef.refreshWeaponButtons();
      gameRef.refreshLifePointsBar();
      if (gameRef.isLoaded) gameRef.updateCamera(x, y);
      if (gameRef.config.mode == GameMode.story) {
        _itemList = List.from(mainCharacter.itemList);
      }
      gameRef.executeAction(
          action: gameRef.map.action, actor: gameRef.playerOne!);
    }
    if (gameRef.config.mode != GameMode.story) {
      isPlayerOne
          ? updateOrientation(_initialOrientation)
          : updateDirection(_initialOrientation);
    }
    return null;
  }

  // Component's tile
  late Tile tile;

  @override
  bool get isPlayerOne => this == gameRef.playerOne;

  // List of weapon owned
  List<Weapon> weaponList = [];

  // Index of the weapon selected from weaponList
  int selectedWeaponIndex = 0;

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
      mainCharacter.minutesPlayed + gameRef.elapsedSeconds / 60;

  // List of items owned
  // Add/remove items by using addItem() and removeItem()
  List<String> _itemList = [];
  List<String> get itemList => _itemList;
  List<Item> get backpackItems => _itemList.fold([],
      (p, e) => itemData.keys.contains(e) ? (p..add(itemData[e]!..id = e)) : p)
    ..sort((a, b) => a.name.compareTo(b.name));
  int get gemCount => _itemList.where((e) => e.startsWith('gem_')).length;

  // Initial orientation
  late Direction _initialOrientation;

  // NPC features: If friendly it doesn't shoot. If quiet it doesn't move.
  late bool friendly;
  late bool quiet;
  late NpcController npcController = NpcController(
      tile.properties['movementPattern'], tile.properties['shootPattern']);

  @override
  late double maxLifePoints;

  @override
  bool isSolid({DynamicComponent? otherComponent}) => !isBeingDeleted;

  @override
  void playAction(Direction orientation) {
    this.orientation = orientation.opposite;
    super.playAction(orientation);
  }

  // Weapon
  Weapon get selectedWeapon => weaponList[selectedWeaponIndex];
  void shoot() {
    if (isBeingDeleted || gameRef.isPaused) return;
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
    if (gameRef.isNotPaused && isStationary && !isBeingDeleted) {
      componentInFront()?.playAction(orientation);
    }
  }

  // Add item to _itemList
  void addItem(String itemId) {
    _itemList.add(itemId);
    if (isPlayerOne) {
      if (itemData.containsKey(itemId)) {
        gameRef.setMessage(Message(
            gameRef,
            '* {{hero}} puts %s in the backpack. *'
                .i18n
                .fill([itemData[itemId]!.name])));
      } else if (itemId.startsWith('gem_')) {
        gameRef.setMessage(Message(
            gameRef,
            '* {{hero}} puts %s in the backpack. *'
                .i18n
                .fill(['the gem'.i18n.toUpperCase()])));
      }
      gameRef.playSound(Sfx.item);
    }
  }

  // Remove item from _itemList
  void removeItem(String itemId, {bool used = true}) {
    _itemList.remove(itemId);
    if (isPlayerOne) {
      gameRef.setMessage(Message(
          gameRef,
          used
              ? '* {{hero}} used {{selected-item-name}} *'.i18n
              : '* {{hero}} gives %s *'.i18n.fill([itemData[itemId]!.name])));
    }
  }

  @override
  void hasMoved() {
    if (isPlayerOne) gameRef.updateCamera(x, y);
  }

  @override
  void stop() {
    super.stop();
    if (!isPlayerOne) npcController.updateMovement();
  }

  @override
  void collidedBy(DynamicComponent otherComponent) {
    if (!isPlayerOne) super.collidedBy(otherComponent);
  }

  @override
  void delete() {
    if (gameRef.config.mode == GameMode.story) {
      super.delete();
      if (isPlayerOne) {
        gameRef.end();
      } else if (!gameRef.hasAction /*  && gameRef.map.action != null */) {
        gameRef.executeAction(
            action: gameRef.map.action!, actor: gameRef.playerOne);
      }
    } else {
      ++defeats;
      stop();
      respawnAnimation();
      removeChildren();
      gameRef.checkMatchStatus();
    }
  }

  @override
  void respawn() {
    super.respawn();
    for (final weapon in weaponList) {
      weapon.restorePp();
    }
    movesCounter = 0;
    orientation = _initialOrientation;
    direction = null;
    if (isPlayerOne) {
      gameRef.refreshWeaponButtons();
      gameRef.updateCamera(x, y);
    }
  }

  @override
  void update(double dt) {
    if (!isPlayerOne && gameRef.isNotPaused) {
      npcController.shoot(this);
      npcController.move(this);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, gameRef.characterOffset));
  }
}
