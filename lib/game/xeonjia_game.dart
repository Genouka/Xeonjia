import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/background.dart';
import 'package:xeonjia/game/components/character.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/components/modifer.dart';
import 'package:xeonjia/game/models/game_map.dart';
import 'package:xeonjia/game/models/team.dart';
import 'package:xeonjia/game/utils/audio_controller.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/event_manager.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/utils/fire_atlas.dart';
import 'package:xeonjia/game/utils/input_controller.dart';
import 'package:xeonjia/game/utils/little_scheme.dart';
import 'package:xeonjia/game/utils/map_controller.dart';
import 'package:xeonjia/game/utils/map_importer.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/utils/message_manager.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/utils/weapons.dart';
import 'package:xeonjia/game/widgets/boxes/battle_text_box.dart';
import 'package:xeonjia/game/widgets/boxes/dialog_box.dart';
import 'package:xeonjia/game/widgets/boxes/remaining_moves_box.dart';
import 'package:xeonjia/game/widgets/boxes/status_box.dart';
import 'package:xeonjia/game/widgets/buttons/backpack_button.dart';
import 'package:xeonjia/game/widgets/buttons/hide_hints_button.dart';
import 'package:xeonjia/game/widgets/buttons/minimap_button.dart';
import 'package:xeonjia/game/widgets/buttons/rules_button.dart';
import 'package:xeonjia/game/widgets/buttons/world_map_button.dart';
import 'package:xeonjia/game/widgets/loading_page.dart';
import 'package:xeonjia/game/widgets/menus/backpack_menu.dart';
import 'package:xeonjia/game/widgets/menus/end_menu.dart';
import 'package:xeonjia/game/widgets/menus/no_maps_menu.dart';
import 'package:xeonjia/game/widgets/menus/pause_menu.dart';
import 'package:xeonjia/game/widgets/menus/shop_menu.dart';
import 'package:xeonjia/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// Default component dimension
late double componentSize;
void setComponentSize(Size screenSize) => componentSize =
    (screenSize.longestSide / 16).round16.gridAligned.toDouble();

/// This contains the game logics
class XeonjiaGame extends FlameGame
    with KeyboardEvents, PanDetector, HasTappables {
  XeonjiaGame(this.config) {
    camera.speed = 300;
    environment = setEnvironment(this);
    messageManager = MessageManager(this);
    dialogBox = DialogBox(this);
    preLoadDialogAtlases();
    statusBox = StatusBox(this);
    overlayMap = {
      'statusBox': (BuildContext context, XeonjiaGame game) => statusBox,
      'backpackButton': (BuildContext context, XeonjiaGame game) =>
          BackpackButton(game),
      'rulesButton': (BuildContext context, XeonjiaGame game) =>
          RulesButton(game),
      'backpackMenu': (BuildContext context, XeonjiaGame game) {
        backpackMenu = BackpackMenu(this);
        return backpackMenu!;
      },
      'miniMapButton': (BuildContext context, XeonjiaGame game) =>
          MiniMapButton(game, miniMapIsActive: game.miniMapActive),
      'virtualDPad': (BuildContext context, XeonjiaGame game) =>
          VirtualDPad(this),
      'dialogBox': (BuildContext context, XeonjiaGame game) => game.dialogBox,
      'loading': (BuildContext context, XeonjiaGame game) => LoadingPage(),
    };
    if (config.mode != GameMode.story) {
      teams = [
        Team(this, id: 0, name: 'Team A', color: Colors.red),
        Team(this, id: 1, name: 'Team B', color: Colors.green),
      ];
    }
    start();
  }

  @override
  Future<void>? onLoad() {
    if (settings.backgroundMusic && config.mode == GameMode.story) {
      FlameAudio.bgm.initialize();
    }
    return null;
  }

  @override
  void onMount() {
    overlays.add('statusBox');
    if (!overlays.isActive('noMapsMenu')) {
      overlays.add('dialogBox');
      overlays.add('miniMapButton');
      overlays.add('backpackButton');
      overlays.add('loading');
    }
    super.onMount();
  }

  /// Function called when [playerOne] is loaded
  void playerOneReady() {
    overlays.remove('loading');
    overlays.remove('dialogBox');
    overlays.add('virtualDPad');
    overlays.add('dialogBox');
    add(Button.A(this));
    if (config.mode == GameMode.story) {
      add(WorldMapButton());
      overlays.add('miniMapButton');
      overlays.add('backpackButton');
    }
    executeAction(action: map.action, actor: playerOne!);
    if (enemies > 0 && map.startBattle) {
      setMessage(
          Message(
            this,
            (enemies == 1
                    ? 'There is one enemy here!'.i18n
                    : 'There are %s enemies here!'.i18n.fill([enemies])) +
                ' ' +
                "It' time to fight!".i18n,
            translate: false,
          ),
          callback: startBattle);
    }
  }

  /// Reset variables and import [map] data
  void start() async {
    pause(stopMusic: false);
    overlays.remove('mapNameBox');
    overlays.remove('miniMapButton');
    overlays.remove('backpackButton');
    overlays.remove('rulesButton');
    overlays.remove('virtualDPad');

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    elapsed = 0;
    _elapsedSecondsMultiplayer = 0;
    remainingMoves = 3;
    changingTurn = false;
    inBattle = false;
    customBgm = null;

    // Remove previous components
    // They are removed during the next update()
    removeAll(children);
    add(BackgroundComponent());
    players.clear();
    deletedComponents.clear();
    modifiersToBeRegenerated.clear();
    for (final t in teams ?? []) {
      t.basisPoints = 0;
    }

    // Import map and components
    if (config.mode == GameMode.story) {
      map = GameMap(fullId: mainCharacter.visitedRooms.last);
      if (map.id == '44') {
        FlameAudio.bgm.dispose();
        addCustomWidgetOverlay('noMapsMenu', NoMapsMenu(this, '43'));
        return;
      }
      await importMap(this, 'assets/maps/story/${map.id}.tmx');
      miniMapActive = false;
    } else {
      map = GameMap(fullId: config.mapId.toString());
      await importMap(this, 'assets/maps/arena/${config.mapId}.tmx');
      _timer = Timer(1, repeat: true, onTick: () {
        if (isPaused) return;
        _elapsedSecondsMultiplayer++;
        if (config.mode != GameMode.story) {
          if (_elapsedSecondsMultiplayer == config.maxTime) end(timeOut: true);
          if (_elapsedSecondsMultiplayer % 10 == 0) regenerateModifiers();
          statusBox.state?.refresh();
        }
      });
    }
    if (map.hasHints) add(HideHintsButton());
    _timer?.start();
    resume();
    playBackgroundMusic();
  }

  /// Match settings
  final MatchConfig config;

  // Map with widgets overlay
  Map<String, Widget Function(BuildContext, XeonjiaGame)>? overlayMap;
  void addCustomWidgetOverlay(String overlayName, Widget widget) {
    overlays.addEntry(
        overlayName, (BuildContext context, Game gameRef) => widget);
    overlays.add(overlayName);
  }

  /// Scheme's environment
  late Environment environment;

  /// Dialog box
  late DialogBox dialogBox;
  late MessageManager messageManager;

  /// Box with HP, pause, time and team points
  late StatusBox statusBox;

  /// Pause menu
  PauseMenu? pauseMenu;

  /// Backpack menu
  BackpackMenu? backpackMenu;

  /// Shop menu
  ShopMenu? shopMenu;

  /// Elapsed time since room change (in seconds with microseconds precision)
  double elapsed = 0;

  /// Timer used in multiplayer mode
  Timer? _timer;
  int _elapsedSecondsMultiplayer = 0;
  int get remainingTime => config.maxTime - _elapsedSecondsMultiplayer;

  /// If true the game is paused
  bool _pause = false;
  bool get isPaused => _pause;
  bool get isNotPaused => !_pause;

  /// Map properties
  late GameMap map;

  /// Current event log
  /// It is synced with [mainCharacter.eventLog] while changing room
  late Map<String, dynamic> currentEventLog;

  /// If true: hide hints on the maps
  bool hideHints = true;

  /// List of non-friendly [Walker] components in game + [playerOne]
  List<Walker> players = [];
  List<BasicComponent> deletedComponents = [];

  /// Main character
  CharacterComponent? playerOne;

  /// List of teams
  List<Team>? teams;

  /// Battle variables
  Walker? get activePlayer => changingTurn ? null : players[_activePlayerIndex];
  late bool changingTurn;
  late int _activePlayerIndex;
  late int remainingMoves;

  /// Increase the move counter during a battle
  void useMove(Walker component, {bool skipTurn = false}) {
    if (!skipTurn && !(component.isMyTurn && inBattle)) return;
    if (skipTurn || --remainingMoves <= 0) {
      remainingMoves = 3;
      if (++_activePlayerIndex >= players.length) _activePlayerIndex = 0;
      for (int i = _activePlayerIndex; i < players.length; i++) {
        if (!(players[i].deleted || players[i].isBeingDeleted)) {
          changingTurn = true;
          camera.moveTo(Vector2(moveCamera(size.x, map.width, players[i].x),
              moveCamera(size.y, map.height, players[i].y)));
          add(TimerComponent(
              period: 0.7,
              onTick: () {
                if (!inBattle) return;
                if (players[i].deleted || players[i].isBeingDeleted) {
                  useMove(players[i], skipTurn: true);
                } else {
                  _activePlayerIndex = i;
                  changingTurn = false;
                  if (playerOne!.isMyTurn) {
                    overlays.add('backpackButton');
                    if (enemies > 0) overlays.add('rulesButton');
                    overlays.add('miniMapButton');
                    overlays.remove('dialogBox');
                    overlays.add('virtualDPad');
                    overlays.add('dialogBox');
                  } else {
                    overlays.remove('backpackButton');
                    overlays.remove('rulesButton');
                    overlays.remove('miniMapButton');
                    overlays.remove('virtualDPad');
                  }
                }
              }));
          break;
        }
      }
    }
  }

  @override
  FutureOr<void> add(Component component) {
    if (component is Walker &&
        (([-3, -2, 1].contains(component.teamId)) ||
            (component is CharacterComponent &&
                (component.friendly == false ||
                    (component.tile.properties['isPlayerOne'] ?? false))))) {
      players.add(component);
      if (component is CharacterComponent &&
          (component.tile.properties['isPlayerOne'] ?? false)) {
        playerOne = component;
        _activePlayerIndex = players.length - 1;
      }
    }
    return super.add(component);
  }

  @override
  void remove(Component component) {
    if (isEnemy(component) && enemies == 0 && inBattle) endBattle();
    super.remove(component);
  }

  /// Get [BasicComponent] from ID
  BasicComponent? getComponentFromId(int id) {
    var componentList = List.from(children)..addAll(deletedComponents);
    return componentList
        .firstWhereOrNull((c) => c is BasicComponent && c.id == id);
  }

  BasicComponent getActiveComponentFromId(int id) =>
      children.firstWhere((c) => c is BasicComponent && c.id == id)
          as BasicComponent;
  BasicComponent getDeletedComponentFromId(int id) =>
      deletedComponents.firstWhere((c) => c.id == id);

  /// Count enemies (alive) in the room
  int get enemies => players.where((e) => isEnemy(e, onlyAlive: true)).length;
  bool isEnemy(Component c, {bool onlyAlive = false}) =>
      (c is BasicComponent &&
          [-3, -2, 1].contains(c.teamId) &&
          (!c.deleted || !onlyAlive)) ||
      (c is CharacterComponent &&
          c.friendly == false &&
          (!c.deleted || !onlyAlive));

  /// List of [teams] sorted by points
  List<Team> get ranking {
    var list = List.from(teams!).cast<Team>();
    list.sort((a, b) => b.points.compareTo(a.points));
    return list;
  }

  /// List of modifier to be regenerate during the next [regenerateModifiers]
  List<ModifierComponent> modifiersToBeRegenerated = [];

  /// Background music
  String? currentBgm;
  String? customBgm;

  @override
  Color backgroundColor() => const Color(0xFF5D6872);

  @override
  void update(double dt) {
    _timer?.update(dt);
    elapsed += dt;
    inputControllerUpdate(dt);
    super.update(dt);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    setComponentSize(canvasSize.toSize());
    miniMapZoom = 1;
    bool changed = !(hasLayout && this.canvasSize == canvasSize);
    super.onGameResize(canvasSize);
    if (!worldMapEnabled && changed) {
      inBattle
          ? updateCamera(activePlayer?.x ?? 0, activePlayer?.y ?? 0)
          : updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
    }
  }

  /// Start battle and adds HUDs
  bool inBattle = false;
  void startBattle() {
    inBattle = true;
    add(BattleTextBox(size, 'Battle!'.i18n.toUpperCase()));
    add(Button.P(this));
    if (playerOne!.hasWeaponId(1)) add(Button.S(this));
    add(RemainingMovesBox());
    overlays.add('rulesButton');
    playBackgroundMusic(custom: 'enemies');
  }

  /// Battle is over
  void endBattle() {
    inBattle = false;
    overlays.remove('rulesButton');
    camera.moveTo(Vector2(moveCamera(size.x, map.width, playerOne!.x),
        moveCamera(size.y, map.height, playerOne!.y)));
    add(BattleTextBox(size, 'You won!'.i18n.toUpperCase()));
    playBackgroundMusic(custom: null);
    playSound(Sfx.win, volume: 1);
  }

  /// Pause game
  void pause({PauseMode? mode, bool stopMusic = true, bool stopEngine = true}) {
    if (_pause) return;
    _pause = true;
    if (stopEngine) pauseEngine();
    if (stopMusic) FlameAudio.bgm.pause();
    if (mode != null) {
      pauseMenu = PauseMenu(this, mode);
      addCustomWidgetOverlay('pauseMenu', pauseMenu!);
    }
  }

  /// Resume game
  void resume() {
    _pause = false;
    resumeEngine();
    if (settings.backgroundMusic && map.music != 'none') {
      FlameAudio.bgm.resume();
    }
  }

  /// Execute an action
  void executeAction(
      {required String? action, BasicComponent? actor, BasicComponent? self}) {
    if (action?.isEmpty ?? true) return;
    pause(stopEngine: false, stopMusic: false);
    environment.defineSymbol(
        Sym('self'), Intrinsic('self', 0, (Cell? x) => self!));
    environment.defineSymbol(
        Sym('actor'), Intrinsic('actor', 0, (Cell? x) => actor ?? playerOne!));
    _actionContinuation =
        evaluate(readFromTokens(splitStringIntoTokens(action!)), environment);
  }

  /// Continue action execution after (wait)
  Continuation? _actionContinuation;
  bool get hasAction => _actionContinuation != null;
  void clearActionContinuation() => _actionContinuation = null;
  double nextActionDelay = 0;
  void continueAction({double? delay}) {
    if (hasAction) {
      delay ??= nextActionDelay;
      nextActionDelay = 0;
      add(TimerComponent(
        period: delay,
        onTick: () => evaluate(null, environment, _actionContinuation),
      ));
      if (isItemsMenuActive) update(0);
    } else if (!worldMapEnabled && !isItemsMenuActive) {
      resume();
    }
  }

  /// Show a message in the [dialogBox]
  void setMessage(Message? message, {bool? hideMap, VoidCallback? callback}) {
    if (message != null) {
      setMessages([message], hideMap: hideMap ?? false, callback: callback);
    }
  }

  /// Show a list of messages in the [dialogBox]
  void setMessages(List<Message> messages,
      {bool hideMap = false, VoidCallback? callback}) {
    messageManager.setMessages(messages, hideMap: hideMap, callback: callback);
  }

  /// Map xfaFileName -> FireAtlas. Used for dialogs.
  final Map<String, FireAtlas> dialogAtlases = {};
  void preLoadDialogAtlases() {
    for (final xfaFile in ['heads', 'items']) {
      loadCustomAtlas('images/metadata/$xfaFile.xfa').then((value) {
        dialogAtlases[xfaFile] = value;
      });
    }
  }

  /// Save match data and load the new room
  void changeRoom(String nextRoomId) {
    pause(stopMusic: false);
    if (enemies == 0) currentEventLog['${map.id}-safe'] = true;

    // Save new player data into mainCharacter
    mainCharacter.def = playerOne!.def;
    mainCharacter.maxHP = playerOne!.maxHP;
    mainCharacter.currentHP = playerOne!.hp;
    mainCharacter.money = playerOne!.money;
    mainCharacter.defeatedComponents += playerOne!.defeatedEnemies;
    mainCharacter.minutesPlayed += elapsed / 60;
    mainCharacter.movesCounter += playerOne!.movesCounter;
    mainCharacter.visitedRooms.add(nextRoomId);
    mainCharacter.eventLog = Map.from(currentEventLog);
    mainCharacter.itemList = List.from(playerOne!.itemList);
    mainCharacter.weaponList = List.from(playerOne!.weaponList);
    mainCharacter.selectedWeaponIndex = playerOne!.selectedWeaponIndex;
    saveUserData();

    // Load the next room
    start();
  }

  /// Regenerate regenerable modifiers
  void regenerateModifiers() {
    for (final modifier in modifiersToBeRegenerated) {
      modifier.deleted = false;
      add(modifier);
    }
    modifiersToBeRegenerated.clear();
  }

  /// Update [camera] position
  void updateCamera(double x, double y) {
    if (map.width == 0) return;
    camera.snapTo(Vector2(moveCamera(size.x, map.width, x),
        moveCamera(size.y, worldMapEnabled ? map.width * 0.7 : map.height, y)));
  }

  /// Calculate [camera] position
  double moveCamera(double screenSize, num mapSize, double pos) {
    var delta = mapSize * componentSize * miniMapZoom - screenSize;
    return (delta <= 0 ? delta / 2 : max(0, min(pos - screenSize / 2, delta)))
        .gridAligned
        .toDouble();
  }

  /// Mini-map
  bool miniMapEnabled = false;
  bool miniMapActive = false;
  double miniMapZoom = 1;

  /// World map
  bool worldMapEnabled = false;

  /// Buttons used to zoom in and out
  late Button zoomInButton = Button.plus(this);
  late Button zoomOutButton = Button.minus(this);

  /// Open backpack
  void backpack() {
    pause(stopMusic: false);
    overlays.remove('dialogBox');
    overlays.add('backpackMenu');
    overlays.add('dialogBox');
  }

  /// True if [BackpackMenu] or [ShopMenu] are open
  bool get isItemsMenuActive =>
      overlays.isActive('backpackMenu') || overlays.isActive('shopMenu');

  /// Reload HP bar
  void refreshHPBar() => statusBox.state?.refresh();

  /// Explain battles
  void battleRules({bool askForConfirmation = false}) {
    if (askForConfirmation) {
      // i18n: "Do you want to reread the explanation of how to fight?".i18n
      executeAction(action: '''
          (begin
            (dialog '(("Do you want to reread the explanation of how to fight?")))
            (define id "generic-question")
            (answer id '(("Yes" . #t) ("No" . #f)))
            (wait)
            (if (get id)
              (battle-rules)))''');
      return;
    }

    // i18n: '* {{hero}} consults "The Manual of the Perfect Hero" *'.i18n
    setMessage(Message(
        this, '* {{hero}} consults "The Manual of the Perfect Hero" *'));
    final List<String> texts = [
      'Chapter 4: Battles'.i18n,
      'In battle each player has 3 moves per turn.'.i18n,
      "After these 3 moves, it is the opponent's turn.".i18n,
      'A move can be used to walk, use items, attack or examine what is in front of you.'
          .i18n,
      'You should already know the "A" button, it examines objects, plants and people.'
          .i18n,
      'To attack use the "P" button. In this way you punch the enemy in front of you.'
          .i18n,
      if (playerOne!.hasWeaponId(Weapons.snowball.id))
        'Otherwise, throw snowballs with the "S" button in the direction you are looking at.'
            .i18n,
      if (playerOne!.hasWeaponId(Weapons.snowball.id))
        'If you run out of snowballs, get some snow from the snowdrifts around you.'
            .i18n,
      'Remember, enemies also have HP. Hit them multiple times to knock them out!'
          .i18n,
      'And if you have few HP take advantage of a move you have available to eat or drink something you have in your backpack!'
          .i18n,
      "That's all. Good luck!".i18n,
    ];
    // i18n: 'manual'.i18n, 'book'.i18n
    setMessages([
      for (final string in texts)
        Message(this, string, author: '/manual', translate: false)
    ]);
  }

  /// Check if someone won
  void checkMatchStatus() {
    if (teams!.first.points >= config.maxPoints ||
        teams!.last.points >= config.maxPoints) {
      end();
    }
  }

  /// End of the game (defeat in single player or end match in multiplayer)
  void end({bool timeOut = false}) {
    pause();
    int? lostMoney;
    if (config.mode == GameMode.story) {
      mainCharacter.minutesPlayed += elapsed / 60;
      mainCharacter.movesCounter += playerOne!.movesCounter;
      ++mainCharacter.defeatsCounter;
      mainCharacter.currentHP = playerOne!.maxHP;
      lostMoney = mainCharacter.visitedRooms.toSet().length;
      mainCharacter.money -= lostMoney;
      if (mainCharacter.money < 0) mainCharacter.money = 0;
      saveUserData();
    }
    refreshHPBar();
    addCustomWidgetOverlay('endMenu', EndMenu(this, lostMoney ?? 0));
  }

  /// Move [playerOne]
  void movePlayer(Direction direction, {bool slow = false}) {
    if (!_pause &&
        !messageManager.isActive &&
        playerOne!.isMyTurn &&
        elapsed > 0.5) {
      playerOne?.updateDirection(direction, slow: slow);
    }
  }

  @override
  KeyEventResult onKeyEvent(event, keysPressed) =>
      keyboardHandler(event, keysPressed);

  /// True if it's possible to open the backpack
  bool get isBackpackButtonActive => !(messageManager.isActive ||
      hasAction ||
      !playerOne!.isStationary ||
      !playerOne!.isMyTurn);

  /// True if it's possible to open the mini-map
  bool get isMiniMapButtonActive =>
      !(messageManager.isActive || hasAction || !playerOne!.isStationary);

  /// True if the world map is disabled
  bool get worldMapDisabled =>
      !miniMapEnabled || enemies > 0 || map.disableWorldMap;

  /// Handle back button
  Future<bool> onWillPop() {
    miniMapEnabled ? miniMap() : pause(mode: PauseMode.exit);
    return Future.value(false);
  }

  @override
  void onPanStart(DragStartInfo info) => panStartHandler(info);

  @override
  void onPanUpdate(DragUpdateInfo info) => panUpdateHandler(info);

  @override
  void onPanEnd(DragEndInfo info) => panEndHandler(info);

  @override
  void onPanCancel() => panCancelHandler();

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    tapUpHandler(pointerId, info);
    super.onTapUp(pointerId, info);
  }

  @override
  void onRemove() {
    FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
    super.onRemove();
  }
}
