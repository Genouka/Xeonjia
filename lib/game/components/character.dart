import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/utils/lifepoints_bar.dart';
import 'package:xeonjia/game/components/utils/respawn_animation.dart';
import 'package:xeonjia/game/components/utils/text_animation.dart';
import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/models/tile.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/utils/npc_controller.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/utils/weapons.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// Dynamic component used for human-like players
class CharacterComponent extends BasicComponent
    with Walker, LifePointsBar, RespawnAnimation, TextAnimation {
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
    updateOrientation(
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0')));
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
    if (image == '') {
      atlasAsset ??= isPlayerOne ? 'hero.xfa' : 'character_cpu.xfa';
    }
    name ??= isPlayerOne ? 'hero' : 'character_cpu-$teamId';
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
    return null;
  }

  // Component's tile
  @override
  Tile tile;

  @override
  bool get isPlayerOne => this == gameRef.playerOne;

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
  late NpcController npcController = NpcController(this,
      tile.properties['movementPattern'], tile.properties['shootPattern']);

  @override
  late double maxLifePoints;

  @override
  void playAction(Direction orientation) {
    updateOrientation(orientation.opposite);
    super.playAction(orientation);
  }

  // Inspect what is in front of this
  void inspect() {
    if (gameRef.isNotPaused && isStationary && !isBeingDeleted && isMyTurn) {
      BasicComponent? component = componentInFront();
      component?.playAction(orientation);
      if (component?.action != null) gameRef.useMove();
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
      if (used) gameRef.useMove();
      gameRef.setMessage(Message(
          gameRef,
          used
              ? '* {{hero}} used {{selected-item-name}} *'.i18n
              : '* {{hero}} gives %s *'.i18n.fill([itemData[itemId]!.name])));
    }
  }

  @override
  void stop() {
    super.stop();
    if (!isPlayerOne) npcController.updateMovement();
  }

  @override
  void collidedBy(Walker otherComponent, [bool wasStationary = false]) {
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
    if (!isPlayerOne && gameRef.isNotPaused && isMyTurn) {
      npcController.shoot();
      npcController.move();
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas..translate(0, gameRef.characterOffset));
  }
}
