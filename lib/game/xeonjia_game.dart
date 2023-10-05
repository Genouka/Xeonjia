import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Default component dimension
late double componentSize;
void setComponentSize(Size screenSize) => componentSize =
    (screenSize.shortestSide / settings.zoomIn).round16.gridAligned.toDouble();

/// This contains the game logics
class XeonjiaGame extends FlameGame
    with KeyboardEvents, PanDetector, HasTappables {
  XeonjiaGame() {
    camera.speed = 300;
    environment = setEnvironment(this);
    messageManager = MessageManager(this);
    dialogBox = DialogBox(this);
    preLoadDialogAtlases();
    statusBox = StatusBox(this);
    add(_curtain);
    overlayMap = {
      'statusBox': (BuildContext context, XeonjiaGame game) => statusBox,
      'backpackButton': (BuildContext context, XeonjiaGame game) =>
          BackpackButton(game),
      'leafButton': (BuildContext context, XeonjiaGame game) =>
          LeafButton(game),
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
    start();
  }

  @override
  Future<void>? onLoad() {
    if (settings.backgroundMusic) FlameAudio.bgm.initialize();
    return null;
  }

  @override
  void onMount() {
    if (!overlays.isActive('noMapsMenu')) {
      overlays.add('miniMapButton');
      overlays.add('backpackButton');
      overlays.add('leafButton');
      overlays.add('dialogBox');
      overlays.add('loading');
    }
    overlays.add('statusBox');
    super.onMount();
  }

  /// Function called when [playerOne] is loaded
  void playerOneReady() {
    overlays.remove('loading');
    overlays.remove('dialogBox');
    overlays.add('virtualDPad');
    add(Button.A(this));
    add(WorldMapButton());
    overlays.add('miniMapButton');
    overlays.add('backpackButton');
    overlays.add('leafButton');
    overlays.add('dialogBox');
    overlays.remove('statusBox');
    overlays.add('statusBox');
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
    _curtain.start();
    pause(stopMusic: false);
    overlays.remove('mapNameBox');
    overlays.remove('miniMapButton');
    overlays.remove('backpackButton');
    overlays.remove('leafButton');
    overlays.remove('rulesButton');
    overlays.remove('virtualDPad');

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    elapsed = 0;
    _activePlayerIndex = 0;
    remainingMoves = 3;
    changingTurn = false;
    inBattle = false;
    customBgm = null;
    milla = null;
    clearActionContinuation();
    messageManager.clear(soft: true);
    dialogBox.state?.refresh();

    // Remove previous components
    // They are removed during the next update()
    removeAll(children.whereNot((c) => c is CurtainComponent));
    add(BackgroundComponent());
    players.clear();
    deletedComponents.clear();

    // Import map and components
    map = GameMap(fullId: mainCharacter.visitedRooms.last);
    await importMap(this, 'assets/maps/story/${map.id}.tmx');
    miniMapActive = false;
    if (map.hasHints) add(HideHintsButton());
    resume();
    playBackgroundMusic();
  }

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

  /// Curtain during [start]
  final CurtainComponent _curtain = CurtainComponent();

  /// Box with HP, pause and time
  late StatusBox statusBox;

  /// Pause menu
  PauseMenu? pauseMenu;

  /// Backpack menu
  BackpackMenu? backpackMenu;

  /// Shop menu
  ShopMenu? shopMenu;

  /// Elapsed time since room change (in seconds with microseconds precision)
  double elapsed = 0;

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

  /// Main characters
  CharacterComponent? playerOne;
  CharacterComponent? milla;
  CharacterComponent? get september => children.firstWhereOrNull(
          (c) => c is CharacterComponent && c.name == 'september')
      as CharacterComponent?;

  /// Battle variables
  Walker? get activePlayer => changingTurn ? null : players[_activePlayerIndex];
  CharacterComponent? get user =>
      !inBattle || players.isEmpty || activePlayer?.teamId != 0
          ? playerOne
          : activePlayer as CharacterComponent;
  late bool changingTurn;
  int _activePlayerIndex = 0;
  late int remainingMoves;
  bool get thereIsASnowball => children.any((c) => c is SnowballComponent);

  /// Increase the move counter during a battle
  void useMove(Walker component, {bool skipTurn = false}) {
    if (!skipTurn && !(component.isMyTurn && inBattle)) return;
    if (skipTurn || --remainingMoves <= 0) {
      remainingMoves = 3;
      for (int i = _activePlayerIndex + 1;; i++) {
        if (i >= players.length) i = 0;
        if (!(players[i].deleted || players[i].isBeingDeleted)) {
          changingTurn = true;
          bool deletingSomeone = players.any(
              (p) => p is CharacterComponent && !p.deleted && p.isBeingDeleted);
          add(TimerComponent(
              period: deletingSomeone ? 1.8 : 0,
              onTick: () {
                if (!inBattle ||
                    playerOne!.isBeingDeleted ||
                    playerOne!.deleted) return;
                camera.moveTo(Vector2(
                    moveCamera(size.x, map.width, players[i].x),
                    moveCamera(size.y, map.height, players[i].y)));
              }));
          add(TimerComponent(
              period: deletingSomeone ? 2.5 : 0.7,
              onTick: () {
                if (!inBattle ||
                    playerOne!.isBeingDeleted ||
                    playerOne!.deleted) return;
                if (players[i].deleted || players[i].isBeingDeleted) {
                  useMove(players[i], skipTurn: true);
                } else {
                  _activePlayerIndex = i;
                  changingTurn = false;
                  camera.moveTo(Vector2(
                      moveCamera(size.x, map.width, players[i].x),
                      moveCamera(size.y, map.height, players[i].y)));
                  refreshHPBar();
                  if (user!.isMyTurn) {
                    // only if the previous player wasn't user
                    if (!overlays.isActive('backpackButton')) {
                      overlays.add('backpackButton');
                      overlays.add(inBattle ? 'rulesButton' : 'leafButton');
                      overlays.add('miniMapButton');
                      overlays.remove('dialogBox');
                      overlays.add('virtualDPad');
                      overlays.add('dialogBox');
                      overlays.remove('statusBox');
                      overlays.add('statusBox');
                    }
                  } else {
                    overlays.remove('backpackButton');
                    overlays.remove('leafButton');
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
        (([-3, -2, 0, 1].contains(component.teamId)) ||
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
    if (component is CharacterComponent && component.name == 'milla') {
      milla = component;
    }
    return super.add(component);
  }

  @override
  void remove(Component component) {
    if (isEnemy(component) && enemies == 0 && inBattle) endBattle();
    if (inBattle && component is CharacterComponent) {
      if (component == milla) {
        setMessage(Message(
            this,
            'Milla is tired and is back in the leaf, I must continue the battle.'
                .i18n));
      } else if (component.name == 'september') {
        setMessage(Message(
            this,
            (milla?.deleted ?? true)
                ? 'September is tired, I must continue the battle alone.'.i18n
                : 'September is tired, but we must continue the battle.'.i18n));
      }
    }
    super.remove(component);
  }

  /// Get [BasicComponent] from ID
  BasicComponent? getComponentFromId(int id) =>
      (List.from(children)..addAll(deletedComponents))
          .firstWhereOrNull((c) => c is BasicComponent && c.id == id);

  /// Count enemies (alive) in the room
  int get enemies => players.where((e) => isEnemy(e, onlyAlive: true)).length;
  bool isEnemy(Component c, {bool onlyAlive = false}) =>
      (c is BasicComponent &&
          [-3, -2, 1].contains(c.teamId) &&
          (!c.deleted || !onlyAlive)) ||
      (c is CharacterComponent &&
          c.friendly == false &&
          (!c.deleted || !onlyAlive));

  /// Background music
  String? currentBgm;
  String? customBgm;

  @override
  Color backgroundColor() => const Color(0xFF5D6872);

  @override
  void update(double dt) {
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
          : updateCamera(user?.x ?? 0, user?.y ?? 0);
    }
  }

  /// Start battle and adds HUDs
  bool inBattle = false;
  void startBattle() {
    inBattle = true;
    add(BattleTextBox('Battle!'.i18n.toUpperCase()));
    add(Button.P(this));
    if (playerOne!.hasWeaponId(Weapons.snowball.id)) add(Button.S(this));
    if (playerOne!.hasWeaponId(Weapons.mine.id)) add(Button.M(this));
    add(RemainingMovesBox());
    overlays.remove('mapNameBox');
    overlays.add('rulesButton');
    overlays.remove('leafButton');
    playBackgroundMusic(custom: 'enemies');
  }

  /// Battle is over
  void endBattle() {
    inBattle = false;
    changingTurn = false;
    overlays.remove('rulesButton');
    overlays.add('leafButton');
    // only if the previous player wasn't user
    if (!overlays.isActive('backpackButton')) {
      overlays.add('backpackButton');
      overlays.add('miniMapButton');
      overlays.remove('dialogBox');
      overlays.add('virtualDPad');
      overlays.add('dialogBox');
      overlays.remove('statusBox');
      overlays.add('statusBox');
    }
    camera.moveTo(Vector2(moveCamera(size.x, map.width, playerOne!.x),
        moveCamera(size.y, map.height, playerOne!.y)));
    _activePlayerIndex = players.indexOf(playerOne!);
    add(BattleTextBox('You won!'.i18n.toUpperCase()));
    children
        .where((c) => c is ModifierComponent && c.explosionOnDelete)
        .forEach((c) => (c as ModifierComponent).delete());
    playBackgroundMusic(custom: null);
    playSound(Sfx.win, volume: 1);
    statusBox.state?.refresh();
    if (map.action != null) executeAction(action: map.action, actor: playerOne);
  }

  /// Pause game
  void pause({PauseMode? mode, bool stopMusic = true, bool stopEngine = true}) {
    if (elapsed < 0.5 && mode == PauseMode.pause) return;
    if ((hasAction || messageManager.isActive) && mode != null) {
      stopEngine = true;
      stopMusic = true;
      dialogBox.state?.pauseAnimation();
    } else if (_pause) {
      return;
    }
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
    if (!hasAction) _pause = false;
    dialogBox.state?.resumeAnimation();
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
    environment.defineSymbol(
        Sym('user-name'), (user?.name ?? mainCharacter.name).toUpperCase());
    environment.defineSymbol(Sym('minutes-played'),
        (mainCharacter.minutesPlayed + elapsed / 60).round());
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
    mainCharacter.minutesPlayed += elapsed / 60;
    mainCharacter.movesCounter += playerOne!.movesCounter;
    mainCharacter.visitedRooms.add(nextRoomId);
    mainCharacter.eventLog = Map.from(currentEventLog);
    mainCharacter.itemList = List.from(playerOne!.itemList);
    mainCharacter.weaponList = List.from(playerOne!.weaponList);
    saveUserData();

    // Load the next room
    start();
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
  WorldMap? worldMapComponent;

  /// Buttons used to zoom in and out
  late Button zoomInButton = Button.plus(this);
  late Button zoomOutButton = Button.minus(this);

  /// Show Milla
  void millaLeaf() {
    if (isBackpackButtonActive) {
      // i18n: 'Milla is resting.'.i18n
      // i18n: 'Milla is already here!'.i18n
      executeAction(
          action: milla == null || !milla!.isVisible
              ? '''
      (begin
        (milla-in)
        (milla-dialog)
        (wait)
        (milla-out)
        (set-orientation 0)
        (wait 2))'''
              : (milla!.deleted
                  ? '''(dialog '(("Milla is resting.")))'''
                  : '''(dialog '(("Milla is already here!")))'''));
    }
  }

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

  /// Show messages about users' money or HP
  void userStatusMessage({bool money = false}) {
    List<List<String>> messages = [
      [
        if (money)
          "I have %s ¤. I'm not very rich.".i18n.fill([playerOne!.money])
        else
          'I have %s health points.'.i18n.fill([playerOne!.hp.round()]),
        '/hero'
      ],
      if (inBattle && milla != null && milla!.teamId == 0)
        [
          if (money)
            "I don't even have a cent!".i18n
          else
            'I have %s health points!'.i18n.fill([milla!.hp.round()]),
          '/milla_happy'
        ],
      if (!money && inBattle && september != null && september!.teamId == 0)
        [
          'I? I have %s health points.'.i18n.fill([september!.hp.round()]),
          '/september'
        ],
    ];
    setMessages([
      for (final message in messages)
        Message(this, message.first, author: message.last, translate: false)
    ]);
  }

  /// Reload HP bar (it shows [c]'s HP; if null it shows [user]'s HP)
  void refreshHPBar([CharacterComponent? c]) => statusBox.state?.refresh(c);

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
      'You should already know the "%s" button, it examines objects, plants and people.'
          .i18n
          .fill([inspectButtonKey]),
      'To attack use the "%s" button. In this way you punch the enemy in front of you.'
          .i18n
          .fill([punchButtonKey]),
      if (playerOne!.hasWeaponId(Weapons.snowball.id))
        'Otherwise, throw snowballs with the "%s" button in the direction you are looking at.'
            .i18n
            .fill([snowballButtonKey]),
      if (playerOne!.hasWeaponId(Weapons.snowball.id))
        'If you run out of snowballs, get some snow from the snowdrifts around you.'
            .i18n,
      if (playerOne!.hasWeaponId(Weapons.mine.id))
        'Mines you place under you with the "%s" button explode as soon as an enemy steps on them.'
            .i18n
            .fill([mineButtonKey]),
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

  /// End of the game (because HP < 0)
  void end({bool timeOut = false}) {
    pause();
    int? lostMoney;
    mainCharacter.minutesPlayed += elapsed / 60;
    mainCharacter.movesCounter += playerOne!.movesCounter;
    ++mainCharacter.defeatsCounter;
    mainCharacter.currentHP = playerOne!.maxHP;
    lostMoney = mainCharacter.visitedRooms.toSet().length;
    mainCharacter.money -= lostMoney;
    if (mainCharacter.money < 0) mainCharacter.money = 0;
    saveUserData();
    refreshHPBar();
    addCustomWidgetOverlay(
        'youLostMenu', YouLostMenu(this, restartAfterEnd, lostMoney));
  }

  /// Close YouLostMenu and restart the game
  void restartAfterEnd() {
    start();
    overlays.remove('youLostMenu');
  }

  /// Move [user]
  void movePlayer(Direction direction, {bool slow = false}) {
    if (!_pause &&
        !messageManager.isActive &&
        user!.isMyTurn &&
        elapsed > 0.5) {
      user?.updateDirection(direction, slow: slow);
    }
  }

  @override
  KeyEventResult onKeyEvent(event, keysPressed) =>
      keyboardHandler(event, keysPressed);

  /// True if it's possible to open the backpack
  bool get isBackpackButtonActive => !(messageManager.isActive ||
      hasAction ||
      !user!.isStationary ||
      !user!.isMyTurn);

  /// True if it's possible to open the mini-map
  bool get isMiniMapButtonActive => !(messageManager.isActive ||
      hasAction ||
      !user!.isStationary ||
      changingTurn);

  /// True if the world map is disabled
  bool get worldMapDisabled =>
      !miniMapEnabled || inBattle || map.disableWorldMap;

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
  void onPanDown(DragDownInfo info) {
    longPressMoving = false;
    longPressButton = children.firstWhereOrNull(
            (e) => e is Button && e.containsPoint(info.eventPosition.widget))
        as Button?;
    longPressTime = longPressButton != null ? elapsed : double.infinity;
  }

  /// Handle long press on bottom right Buttons
  Button? longPressButton;
  double longPressTime = double.infinity;
  bool longPressMoving = false;

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
