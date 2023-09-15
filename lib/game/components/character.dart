import 'package:xeonjia/game/xeonjia.dart';

/// Dynamic component used for human-like players
class CharacterComponent extends BasicComponent
    with Walker, RenderOffset, HPBar, DeletionAnimation {
  CharacterComponent(
    this.tile, {
    int level = 0,
    double? initialHP,
    List<Weapon>? inputWeaponList,
    team = 0,
  }) : super(tile.id, tile.position!, tile.properties) {
    bool isPlayerOne = tile.properties['isPlayerOne'] ?? false;
    maxHP = initialHP ??
        (isPlayerOne ? mainCharacter.maxHP : (100 + 5 * level).toDouble());
    updateOrientation(
        GetDirection.fromInt(int.parse(tile.properties['orientation'] ?? '0')));
    _initialOrientation = orientation;
    friendly = 'true' == (tile.properties['friendly'] ?? 'true');
    quiet = 'true' == (tile.properties['quiet'] ?? 'true');
    if (team == 0) {
      atk = mainCharacter.atk;
      def = mainCharacter.def;
    } else {
      def = def != 0 ? def : 0;
      if (isPlayerOne) {
        weaponList = [
          PunchWeapon(level: 10),
          SnowBallWeapon(level: 5),
          MineWeapon(level: 3),
        ];
      }
    }
    teamId = team;
    name ??= isPlayerOne ? 'hero' : 'unknown';
    if (['hero', 'milla', 'september'].contains(name)) atlasAsset = '$name.xfa';
    if (weaponList.isEmpty) {
      weaponList = inputWeaponList ??
          ((team == 0)
              ? [SnowBallWeapon(level: 5), MineWeapon(level: 1)]
              : [SnowBallWeapon(level: 9), MineWeapon(level: 5)]);
    }
    if (hasWeaponId(Weapons.mine.id)) {
      getWeaponById(Weapons.mine.id).restorePp();
    }
    if (name == 'milla' ||
        (name == 'september' && tile.properties['hp'] == null)) {
      maxHP = mainCharacter.maxHP;
      weaponList = List.from(
          mainCharacter.weaponList.map((e) => Weapon.fromJson(e.toJson())));
      for (final w in weaponList) {
        w.restorePp();
      }
    }
    if (isPlayerOne) {
      // i18n: 'We must fight, not talk!'.i18n
      action = '''(dialog '(("/" "We must fight, not talk!")))''';
    }
  }

  /// Non-Player Character
  CharacterComponent.npc(Tile tile)
      : this(
          tile,
          initialHP: double.parse(tile.properties['hp'] ?? 'Infinity'),
          team: int.parse(tile.properties['team'] ?? '0'),
          inputWeaponList: [
            SnowBallWeapon.fromAtk(
                atk: int.parse(tile.properties['weaponAtk'] ?? '0'),
                powerPoints: 9999)
          ],
          level: int.parse(tile.properties['level'] ?? '0'),
        );

  @override
  Future<void>? onLoad() {
    super.onLoad();
    if (tile.properties['isPlayerOne'] ?? false) {
      setStatus(mainCharacter.currentHP <= 0 ? maxHP : mainCharacter.currentHP,
          mainCharacter.poisonQuantity);
      gameRef.refreshHPBar();
      if (gameRef.isLoaded) gameRef.updateCamera(x, y);
      _itemList = List.from(mainCharacter.itemList);
      gameRef.playerOneReady();
    } else {
      this.add(NpcController());
    }
    if (!deleted && !isBeingDeleted) {
      reflection = IceReflection(this);
      gameRef.add(reflection!);
    }
    return null;
  }

  /// Component's tile
  @override
  Tile tile;

  /// Money earned by the player
  int _money = mainCharacter.money;
  int get money => _money;
  void moneyDifference(int moneyDelta) {
    if (moneyDelta != 0) _money += moneyDelta;
  }

  /// Total number of minutes played by the character in this game
  double get minutesPlayed =>
      mainCharacter.minutesPlayed + gameRef.elapsed / 60;

  /// List of [Item]s owned
  /// Add/remove [Item]s by using [addItem] and [removeItem]
  List<String> _itemList = [];
  List<String> get itemList => _itemList;
  List<Item> get backpackItems => _itemList.fold([],
      (p, e) => itemData.keys.contains(e) ? (p..add(itemData[e]!..id = e)) : p)
    ..sort((a, b) => a.name.compareTo(b.name));
  int get gemCount => _itemList.where((e) => e.startsWith('gem_')).length;

  /// Initial orientation
  late Direction _initialOrientation;

  @override
  late double maxHP;

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
      if ((component?.action ?? '') != '') {
        gameRef.playSound(Sfx.dialog);
        gameRef.useMove(this);
      }
    }
  }

  /// Add item to _itemList
  void addItem(String itemId, {bool sfx = true}) {
    _itemList.add(itemId);
    if (isUser) {
      if (itemData.containsKey(itemId)) {
        gameRef.setMessage(Message(
          gameRef,
          '* {{hero}} puts %s in the backpack *'
              .i18n
              .fill([itemData[itemId]!.name]),
          author: '-/$itemId',
          xfaFile: 'items',
        ));
      } else if (itemId.startsWith('gem_')) {
        gameRef.setMessage(Message(
          gameRef,
          '* {{hero}} puts %s in the backpack *'.i18n.fill(['the gem'.i18n]),
          author: '-/gem_*',
          xfaFile: 'items',
        ));
      }
      if (sfx) gameRef.playSound(Sfx.item);
    }
  }

  /// Remove item from _itemList
  void removeItem(String itemId, {bool used = true}) {
    _itemList.remove(itemId);
    if (isUser) {
      if (used) gameRef.useMove(gameRef.user ?? this);
      gameRef.setMessage(Message(
          gameRef,
          used
              ? (gameRef.user?.isPlayerOne ?? true
                  ? '* {{hero}} uses {{selected-item-name}} *'.i18n
                  : '* {{user-name}} uses {{selected-item-name}} *'.i18n)
              : '* {{hero}} gives %s *'.i18n.fill([itemData[itemId]!.name])));
    }
  }

  @override
  void collidedBy(Walker otherComponent, [bool wasStationary = false]) {
    if (!isUser) super.collidedBy(otherComponent);
  }

  @override
  void delete({bool silently = false}) {
    stop();
    isBeingDeleted = true;
    reflection?.removeFromParent();
    if (silently) {
      super.delete();
      if (isPlayerOne) gameRef.end();
    } else {
      if (isPlayerOne) gameRef.playSound(Sfx.gameover);
      gameRef.pause(stopMusic: false, stopEngine: false);
      deletionAnimation(callback: () {
        gameRef.resume();
        if (isBeingDeleted) super.delete();
        if (isPlayerOne) gameRef.end();
      });
    }
  }

  @override
  void respawn(XeonjiaGame gameRef) {
    super.respawn(gameRef);
    for (final weapon in weaponList) {
      weapon.restorePp();
    }
    updateOrientation(_initialOrientation);
    direction = null;
    if (isPlayerOne) gameRef.updateCamera(x, y);
  }
}
