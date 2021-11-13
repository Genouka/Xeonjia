import 'dart:math';

import 'package:flame/bgm.dart';
import 'package:flame/components/timer_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flame/sprite.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/background.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/util/event_manager.dart';
import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/util/little_scheme.dart';
import 'package:xeonjia/game/util/map_importer.dart';
import 'package:xeonjia/game/util/message_manager.dart';
import 'package:xeonjia/game/util/wireless_gamepad.dart';
import 'package:xeonjia/game/widgets/backpack_button.dart';
import 'package:xeonjia/game/widgets/backpack_menu.dart';
import 'package:xeonjia/game/widgets/dialog_box.dart';
import 'package:xeonjia/game/widgets/end_menu.dart';
import 'package:xeonjia/game/widgets/map_name_box.dart';
import 'package:xeonjia/game/widgets/minimap_button.dart';
import 'package:xeonjia/game/widgets/no_maps_menu.dart';
import 'package:xeonjia/game/widgets/pause_menu.dart';
import 'package:xeonjia/game/widgets/status_box.dart';
import 'package:xeonjia/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/map_properties.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Main game variable
XeonjiaGame game;

// Default component speed (componentSize per second)
double get defaultSpeed => componentSize * 8;

// Default component dimension
double componentSize;

// Vertical offset used to translate characters
double get characterOffset => -(componentSize *
        ((game?.miniMapEnabled ?? false) ? game.miniMapZoom : 1) /
        8)
    .gridAligned;

// Xeonjia game class
class XeonjiaGame extends BaseGame
    with HasWidgetsOverlay, PanDetector, TapDetector, KeyboardEvents {
  // Match settings
  final MatchConfig config;

  XeonjiaGame(this.config) {
    addWidgetOverlay('statusBox', _statusBox);
    addWidgetOverlay('virtualGamePad', _virtualGamePad);
    addWidgetOverlay('dialogBox', dialogBox);
    initGamepad();
    if (settings.backgroundMusic && config.mode == GameMode.story) {
      _backgroundMusic = Bgm();
      _backgroundMusic.initialize();
    }
    if (config.mode == GameMode.story) {
      addWidgetOverlay('miniMapButton', MiniMapButton(miniMapIsActive: false));
      addWidgetOverlay('backpackButton', BackpackButton());
    } else {
      teams = [
        Team(id: 0, name: 'Team A', color: Colors.red),
        Team(id: 1, name: 'Team B', color: Colors.green),
      ];
    }
    init();
  }

  @override
  bool recordFps() => true;

  // Scheme's environment
  final Environment environment = setEnvironment();

  // Dialog box
  final DialogBox dialogBox = DialogBox();
  final MessageManager messageManager = MessageManager();

  // Box with lifePoints, pause, time and team points
  final StatusBox _statusBox = StatusBox();

  // Virtual Gamepad (D-pad + buttons)
  final VirtualGamePad _virtualGamePad = VirtualGamePad();

  // Timer used in multiplayer mode
  Timer _timer;
  int elapsedSeconds = 0;
  int get remainingTime => config.maxTime - elapsedSeconds;

  // If true the game is paused
  bool _pause;
  bool get isPaused => _pause;
  bool get isNotPaused => !_pause;

  // Map properties
  MapProperties map;

  // Current event log
  // It is synced with mainCharacter.eventLog while changing room
  Map<String, dynamic> currentEventLog;

  // List of CharacterComponent in game
  List<CharacterComponent> players = [];
  List<BasicComponent> deletedComponents = [];

  // Main character
  CharacterComponent playerOne;

  // List of teams
  List<Team> teams;

  // Get component from ID
  BasicComponent getComponentFromId(int id) {
    var componentList = List.from(components)..addAll(deletedComponents);
    return componentList.firstWhere((c) => c is BasicComponent && c.id == id);
  }

  BasicComponent getActiveComponentFromId(int id) =>
      components.firstWhere((c) => c is BasicComponent && c.id == id);
  BasicComponent getDeletedComponentFromId(int id) =>
      deletedComponents.firstWhere((c) => c.id == id);

  // Count enemies in the room
  int get enemies => game.components
      .where((e) =>
          (e is BasicComponent &&
              [-3, -2, 1].contains(e.teamId) &&
              !e.remove) ||
          (e is CharacterComponent && e.friendly == false && !e.remove))
      .length;

  // List of teams sorted by points
  List<Team> get ranking {
    var list = List.from(teams).cast<Team>();
    list.sort((a, b) => b.points.compareTo(a.points));
    return list;
  }

  // List of modifier to be regenerate during the next regenerateModifiers()
  List<ModifierComponent> modifiersToBeRegenerated = [];

  // Wireless gamepad
  FlameGamepad gamepad;

  // Background music
  Bgm _backgroundMusic;
  String currentBgm;

  @override
  Color backgroundColor() => const Color(0xFF5D6872);

  // Reset variables and import map data
  void init() async {
    pause(stopMusic: false);
    removeWidgetOverlay('mapNameBox');
    removeWidgetOverlay('miniMapButton');
    removeWidgetOverlay('backpackButton');

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    elapsedSeconds = 0;

    // Remove previous components
    // They are removed during the next update()
    for (var component in components) {
      markToRemove(component);
    }
    players.clear();
    deletedComponents.clear();
    modifiersToBeRegenerated.clear();
    for (var t in (teams ?? [])) {
      t.basisPoints = 0;
    }

    // Import map and components
    if (config.mode == GameMode.story) {
      map = MapProperties(fullId: mainCharacter.visitedRooms.last);
      if (map.id == '44') {
        removeWidgetOverlay('loading');
        _backgroundMusic?.dispose();
        addWidgetOverlay('noMapsMenu', const NoMapsMenu('43'));
        return;
      }
      await importMap('assets/maps/story/${map.id}.tmx');
      addWidgetOverlay('miniMapButton', MiniMapButton(miniMapIsActive: false));
      addWidgetOverlay('backpackButton', BackpackButton());
    } else {
      map = MapProperties(fullId: config.mapId.toString());
      await importMap('assets/maps/arena/${config.mapId}.tmx');
    }

    _timer = Timer(1, repeat: true, callback: () {
      if (isPaused) return;
      elapsedSeconds++;
      if (config.mode != GameMode.story) {
        if (elapsedSeconds == config.maxTime) end(timeOut: true);
        if (elapsedSeconds % 10 == 0) regenerateModifiers();
        _statusBox.state.refresh();
      }
    });
    _timer.start();
    game.addLater(BackgroundComponent(0, 0, Sprite('background.png')));
    update(0);
    resume();
    playBackgroundMusic();
  }

  @override
  void update(double t) {
    _timer?.update(t);
    super.update(t);
  }

  @override
  void resize(Size size) {
    componentSize = (size.longestSide / 16).round16.gridAligned;
    miniMapZoom = 1;
    super.resize(size);
    updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
  }

  // Pause game
  void pause({PauseMode mode, bool stopMusic = true, bool stopEngine = true}) {
    if (_pause ?? false) return;
    _pause = true;
    if (stopEngine) pauseEngine();
    if (stopMusic) _backgroundMusic?.pause();
    if (mode != null) addWidgetOverlay('pauseMenu', PauseMenu(mode));
  }

  // Resume game
  void resume() {
    _pause = false;
    resumeEngine();
    _backgroundMusic?.resume();
  }

  // Execute an action
  void executeAction(
      {@required String action, BasicComponent actor, BasicComponent self}) {
    if (action?.isEmpty ?? true) return;
    pause(stopEngine: false, stopMusic: false);
    environment.defineSymbol(
        Sym('self'), Intrinsic('self', 0, (Cell x) => self));
    environment.defineSymbol(Sym('actor'), actor ?? playerOne);
    _actionContinuation =
        evaluate(readFromTokens(splitStringIntoTokens(action)), environment);
  }

  // Continue action execution after (wait)
  Continuation _actionContinuation;
  bool get hasAction => _actionContinuation != null;
  void clearActionContinuation() => _actionContinuation = null;
  double nextActionDelay = 0;
  void continueAction({double delay}) {
    if (hasAction) {
      delay ??= nextActionDelay;
      nextActionDelay = 0;
      addLater(TimerComponent(Timer(
        delay,
        callback: () => evaluate(null, environment, _actionContinuation),
        repeat: false,
      )..start()));
    } else {
      resume();
    }
  }

  // Show a message in messageBox
  void setMessage(Message message, {bool hideMap}) {
    if (message != null) setMessages([message], hideMap: hideMap);
  }

  // Show a list of messages in messageBox
  void setMessages(List<Message> messages, {bool hideMap = false}) {
    messageManager.setMessages(messages, hideMap: hideMap);
  }

  // Start the background music
  void playBackgroundMusic() {
    if (!settings.backgroundMusic || messageManager.hideMap) return;
    var newBgm = (map.music ?? 'road') + '.oga';
    if (newBgm == currentBgm) return;
    currentBgm = newBgm;
    _backgroundMusic?.stop();
    Future.delayed(const Duration(seconds: 1), () {
      if (game != null) _backgroundMusic?.play('bgm/' + currentBgm);
    });
  }

  // Play sound effect
  void playSound(Sfx sfx) {
    if (settings.soundEffects) Flame.audio.play(sfx.fileName, volume: 0.3);
  }

  // Save match data and load the new room
  void changeRoom(String nextRoomId, {bool enterNextRoom = true}) {
    pause(stopMusic: false);
    if (game.enemies == 0) {
      currentEventLog['${map.id}-safe'] = true;
      mainCharacter.expGained(playerOne.experiencePoints);
    }

    // Save new player data into mainCharacter
    mainCharacter.def = playerOne.def;
    mainCharacter.maxLifePoints = playerOne.maxLifePoints;
    mainCharacter.currentLifePoints = playerOne.lifePoints;
    mainCharacter.money = playerOne.money;
    mainCharacter.defeatedComponents += playerOne.defeatedEnemies;
    mainCharacter.minutesPlayed += elapsedSeconds / 60;
    mainCharacter.movesCounter += playerOne.movesCounter;
    mainCharacter.visitedRooms.add(nextRoomId);
    mainCharacter.eventLog = Map.from(currentEventLog);
    mainCharacter.itemList = List.from(playerOne.itemList);
    mainCharacter.weaponList = List.from(playerOne.weaponList);
    mainCharacter.selectedWeaponIndex = playerOne.selectedWeaponIndex;
    saveUserData();

    // Load the next room
    if (enterNextRoom) init();
  }

  // Regenerate regenerable modifiers
  void regenerateModifiers() {
    for (var modifier in modifiersToBeRegenerated) {
      modifier.remove = false;
      components.add(modifier);
    }
    modifiersToBeRegenerated.clear();
  }

  // Update camera position
  void updateCamera(double x, double y, [double _componentSize]) {
    if (map?.width == null || size == null) return;
    _componentSize ??= componentSize;
    camera.x = _moveCamera(_componentSize, size.width, map.width, x);
    camera.y = _moveCamera(_componentSize, size.height, map.height, y);
  }

  // Calculate camera position
  double _moveCamera(
      double _componentSize, double screenSize, int mapSize, double pos) {
    var delta = mapSize * _componentSize - screenSize;
    return (delta <= 0 ? delta / 2 : max(0, min(pos - screenSize / 2, delta)))
        .gridAligned;
  }

  // Mini-map (componentSize = componentSize * miniMapZoom)
  bool miniMapEnabled = false;
  double miniMapZoom = 1;

  // Enable/Disable mini-map view
  void miniMap() {
    miniMapEnabled = !miniMapEnabled;
    if (miniMapEnabled) {
      zoomMiniMap(toValue: miniMapZoom, enable: true);
      pause(stopEngine: false, stopMusic: false);
      _statusBox.state.refresh();
      removeWidgetOverlay('mapNameBox');
      addWidgetOverlay('mapNameBox', MapNameBox(below: false));
      removeWidgetOverlay('miniMapButton');
      addWidgetOverlay('miniMapButton', MiniMapButton(miniMapIsActive: true));
      removeWidgetOverlay('backpackButton');
      refreshWeaponButtons();
    } else {
      updateCamera(playerOne.x, playerOne.y);
      removeWidgetOverlay('mapNameBox');
      removeWidgetOverlay('miniMapButton');
      addWidgetOverlay('miniMapButton', MiniMapButton(miniMapIsActive: false));
      addWidgetOverlay('backpackButton', BackpackButton());
      refreshWeaponButtons();
      _statusBox.state.refresh();
      resume();
    }
  }

  // Change mini-map zoom
  void zoomMiniMap({double toValue, bool out = false, bool enable = false}) {
    var previousValue = enable ? 1.0 : miniMapZoom;
    var delta = 16 / componentSize;
    miniMapZoom = (toValue ??
        (out
            ? max(previousValue - delta, delta)
            : min(previousValue + delta, 2)));
    updateCamera(playerOne.x * miniMapZoom, playerOne.y * miniMapZoom,
        (componentSize * miniMapZoom).gridAligned);
    onPanUpdate(DragUpdateDetails(globalPosition: Offset.zero));
  }

  // Open backpack
  void backpack() {
    pause(stopMusic: false);
    addWidgetOverlay('backpackMenu', BackpackMenu());
  }

  // Reload weapon buttons
  void refreshWeaponButtons() {
    _virtualGamePad.refresh();
  }

  // Reload LP bar
  void refreshLifePointsBar() {
    _statusBox.state?.refresh();
  }

  // Check if someone won
  void checkMatchStatus() {
    if (teams.first.points >= config.maxPoints ||
        teams.last.points >= config.maxPoints) {
      end();
    }
  }

  // End of the game (defeat in single player or end match in multiplayer)
  void end({bool timeOut = false}) {
    pause();
    int lostMoney;
    if (config.mode == GameMode.story) {
      mainCharacter.minutesPlayed += elapsedSeconds / 60;
      mainCharacter.movesCounter += playerOne.movesCounter;
      ++mainCharacter.defeatsCounter;
      mainCharacter.currentLifePoints = playerOne.maxLifePoints;
      lostMoney = mainCharacter.visitedRooms.toSet().length;
      mainCharacter.money -= lostMoney;
      if (mainCharacter.money < 0) mainCharacter.money = 0;
      saveUserData();
    }
    refreshLifePointsBar();
    addWidgetOverlay('endMenu', EndMenu(lostMoney));
  }

  Offset _panGestureOffset;

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (!_pause && (details.delta.dx.abs() > 5 || details.delta.dy.abs() > 5)) {
      _panGestureOffset = details.delta.dx.abs() > details.delta.dy.abs()
          ? Offset(details.delta.dx, 0)
          : Offset(0, details.delta.dy);
      playerOne?.updateOrientation(GetDirection.fromOffset(_panGestureOffset));
    } else if (miniMapEnabled) {
      camera.x = _moveCamera(componentSize * miniMapZoom, size.width, map.width,
          camera.x - details.delta.dx + size.width / 2);
      camera.y = _moveCamera(componentSize * miniMapZoom, size.height,
          map.height, camera.y - details.delta.dy + size.height / 2);
    }
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onPanEnd(DragEndDetails _) {
    if (_panGestureOffset != null) {
      gestureDragInput(GetDirection.fromOffset(_panGestureOffset));
    }
  }

  @override
  void onTapDown(TapDownDetails details) {
    messageManager.active
        ? dialogBox.state.next()
        : gestureTapInput(details.globalPosition);
  }

  // Manage drag gestures
  void gestureDragInput(Direction direction) {
    if (!_pause && !messageManager.active) {
      playerOne?.updateDirection(direction);
    }
  }

  // Manage tap gesture
  void gestureTapInput(Offset position) {
    if (_pause) return;

    // Update orientation
    var _relativeTapX =
        position.dx - (playerOne.x + componentSize / 2 - camera.x);
    var _relativeTapY =
        position.dy - (playerOne.y + componentSize / 2 - camera.y);

    if (position.dx < componentSize ||
        position.dx > size.width - componentSize) {
      playerOne.updateOrientation(
          GetDirection.fromXY(position.dx - componentSize, 0));
    } else if (position.dy < componentSize ||
        position.dy > size.height - componentSize) {
      playerOne.updateOrientation(
          GetDirection.fromXY(0, position.dy - componentSize));
    } else if (_relativeTapX.abs() > 15 || _relativeTapY.abs() > 15) {
      _relativeTapX.abs() > _relativeTapY.abs()
          ? playerOne.updateOrientation(GetDirection.fromXY(_relativeTapX, 0))
          : playerOne.updateOrientation(GetDirection.fromXY(0, _relativeTapY));
    }

    // Use weapon selected by player
    playerOne.shoot();
  }

  @override
  void onKeyEvent(event) {
    if (event is! RawKeyUpEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      gestureDragInput(Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      gestureDragInput(Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      gestureDragInput(Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      gestureDragInput(Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      playerOne.shoot();
    } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
      playerOne.updateOrientation(Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      playerOne.updateOrientation(Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      playerOne.updateOrientation(Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      playerOne.updateOrientation(Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (isPaused) {
        removeWidgetOverlay('pauseMenu');
        resume();
      } else {
        pause(mode: PauseMode.pause);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
      miniMap();
    }
  }

  void dispose() {
    _backgroundMusic?.stop();
    _backgroundMusic?.dispose();
    gamepad?.removeListener();
    game = null;
  }
}
