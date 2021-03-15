import 'dart:async';
import 'dart:math';
import 'package:flame/bgm.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/util/event_manager.dart';
import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/util/map_importer.dart';
import 'package:xeonjia/game/util/message_manager.dart';
import 'package:xeonjia/game/util/wireless_gamepad.dart';
import 'package:xeonjia/game/widgets/end_menu.dart';
import 'package:xeonjia/game/widgets/map_name_box.dart';
import 'package:xeonjia/game/widgets/minimap_button.dart';
import 'package:xeonjia/game/widgets/status_box.dart';
import 'package:xeonjia/game/widgets/dialog_box.dart';
import 'package:xeonjia/game/widgets/loading_page.dart';
import 'package:xeonjia/game/widgets/no_maps_menu.dart';
import 'package:xeonjia/game/widgets/pause_menu.dart';
import 'package:xeonjia/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/map_properties.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/util/little_scheme.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/util/screen_dimension.dart';

// Main game variable
XeonjiaGame game;

// Default component speed (componentSize per second)
double defaultSpeed;

// Default component dimension
double componentSize;

// Vertical offset used to translate dynamic components
double characterOffset;

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

  // If true, game is paused so no one can move
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

  // Main character
  CharacterComponent playerOne;

  // List of teams
  List<Team> teams;

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
    addWidgetOverlay('loading', LoadingPage());
    removeWidgetOverlay('mapBox');
    removeWidgetOverlay('miniMapButton');

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    elapsedSeconds = 0;

    // Remove previous components
    // They are removed during the next update()
    components.forEach((component) {
      markToRemove(component);
    });
    players.clear();
    modifiersToBeRegenerated.clear();
    teams?.forEach((t) => t.basisPoints = 0);

    // Import map and components
    if (config.mode == GameMode.story) {
      map = MapProperties(fullId: mainCharacter.visitedRooms.last);
      if (map.id == 't1_01') {
        removeWidgetOverlay('loading');
        _backgroundMusic?.dispose();
        addWidgetOverlay('noMapsMenu', NoMapsMenu());
        return;
      }
      await importMap('assets/maps/story/${map.id}.tmx');
      addWidgetOverlay('miniMapButton', MiniMapButton(miniMapIsActive: false));
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
    update(0);
    removeWidgetOverlay('loading');
    resume();
    playBackgroundMusic();
  }

  @override
  void update(double dt) {
    _timer?.update(dt);
    super.update(dt);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
    super.resize(size);
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
    if ((action ?? '') == '') return;
    game.environment
        .defineSymbol(Sym('self'), Intrinsic('self', 0, (Cell x) => self));
    environment.defineSymbol(Sym('actor'), actor ?? playerOne);
    evaluate(readFromTokens(splitStringIntoTokens(action)), game.environment);
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
    _backgroundMusic.stop();
    Future.delayed(const Duration(seconds: 1), () {
      if (game != null) _backgroundMusic.play('bgm/' + currentBgm);
    });
  }

  // Play sound effect
  void playSound(Sfx sfx) {
    if (settings.soundEffects) Flame.audio.play(sfx.fileName, volume: 0.3);
  }

  // Save match data and load the new room
  void changeRoom(String nextRoomId) {
    pause(stopMusic: false);
    if (game.components
        .where((element) =>
            element is BasicComponent && [-3, -2, 1].contains(element.teamId))
        .isEmpty) {
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

    // Start a new game
    init();
  }

  // Regenerate regenerable modifiers
  void regenerateModifiers() {
    modifiersToBeRegenerated.forEach((modifier) {
      modifier.remove = false;
      components.add(modifier);
    });
    modifiersToBeRegenerated.clear();
  }

  // Update camera position
  void updateCamera(double x, double y, [double _componentSize]) {
    if (map?.width == null) return;
    _componentSize ??= componentSize;
    camera.x = _moveCamera(_componentSize, screenSize.width, map.width, x);
    camera.y = _moveCamera(_componentSize, screenSize.height, map.height, y);
  }

  // Calculate camera position
  double _moveCamera(
      double _componentSize, double screenSize, int mapSize, double pos) {
    var delta = mapSize * _componentSize - screenSize;
    return (delta <= 0 ? delta / 2 : max(0, min(pos - screenSize / 2, delta)))
        .gridAligned;
  }

  // Mini-map (componentSize = componentSize / miniMapZoom)
  bool miniMapEnabled = false;
  double _miniMapZoom;

  // Enable/Disable mini-map view
  void miniMap() {
    miniMapEnabled = !miniMapEnabled;
    if (miniMapEnabled) {
      zoomMiniMap(toValue: _miniMapZoom ?? 2, enable: true);
      pause(stopEngine: false, stopMusic: false);
      _statusBox.state.refresh();
      game.removeWidgetOverlay('mapNameBox');
      game.addWidgetOverlay('mapNameBox', MapNameBox(below: false));
      game.removeWidgetOverlay('miniMapButton');
      game.addWidgetOverlay(
          'miniMapButton', MiniMapButton(miniMapIsActive: true));
      refreshWeaponButtons();
    } else {
      zoomMiniMap(toValue: 1);
      updateCamera(playerOne.x, playerOne.y);
      game.removeWidgetOverlay('mapNameBox');
      game.removeWidgetOverlay('miniMapButton');
      game.addWidgetOverlay(
          'miniMapButton', MiniMapButton(miniMapIsActive: false));
      refreshWeaponButtons();
      _statusBox.state.refresh();
      resume();
    }
  }

  // Change mini-map zoom
  void zoomMiniMap({double toValue, bool out = false, bool enable = false}) {
    var previousValue = enable ? 1.0 : _miniMapZoom;
    var tempMapZoom = (toValue ??
        (out ? min(_miniMapZoom + 0.5, 3) : max(_miniMapZoom - 0.5, 0.5)));
    _miniMapZoom = componentSize / (componentSize / tempMapZoom).gridAligned;
    var ratio = previousValue / _miniMapZoom;
    components.forEach((c) {
      if (c is SpriteComponent) {
        c.width *= ratio;
        c.height *= ratio;
        c.x *= ratio;
        c.y *= ratio;
      }
    });
    if (toValue == 1) _miniMapZoom = previousValue;
    updateCamera(playerOne.x, playerOne.y, componentSize / _miniMapZoom);
    onPanUpdate(DragUpdateDetails(globalPosition: Offset.zero));
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
    var lostMoney;
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
  void onPanUpdate(DragUpdateDetails upd) {
    if (!_pause && (upd.delta.dx.abs() > 5 || upd.delta.dy.abs() > 5)) {
      _panGestureOffset = upd.delta.dx.abs() > upd.delta.dy.abs()
          ? Offset(upd.delta.dx, 0)
          : Offset(0, upd.delta.dy);
      playerOne?.updateOrientation(GetDirection.fromOffset(_panGestureOffset));
    } else if (miniMapEnabled) {
      camera.x = _moveCamera(componentSize / _miniMapZoom, screenSize.width,
          map.width, camera.x - upd.delta.dx + screenSize.width / 2);
      camera.y = _moveCamera(componentSize / _miniMapZoom, screenSize.height,
          map.height, camera.y - upd.delta.dy + screenSize.height / 2);
    }
  }

  @override
  void onPanEnd(DragEndDetails end) {
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
        position.dx > screenSize.width - componentSize) {
      playerOne.updateOrientation(
          GetDirection.fromXY(position.dx - componentSize, 0));
    } else if (position.dy < componentSize ||
        position.dy > screenSize.height - componentSize) {
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
  void onKeyEvent(e) {
    if (e is! RawKeyUpEvent) return;
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      gestureDragInput(Direction.down);
    } else if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
      gestureDragInput(Direction.up);
    } else if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      gestureDragInput(Direction.right);
    } else if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      gestureDragInput(Direction.left);
    } else if (e.logicalKey == LogicalKeyboardKey.space) {
      playerOne.shoot();
    } else if (e.logicalKey == LogicalKeyboardKey.keyA) {
      playerOne.updateOrientation(Direction.left);
    } else if (e.logicalKey == LogicalKeyboardKey.keyW) {
      playerOne.updateOrientation(Direction.up);
    } else if (e.logicalKey == LogicalKeyboardKey.keyD) {
      playerOne.updateOrientation(Direction.right);
    } else if (e.logicalKey == LogicalKeyboardKey.keyS) {
      playerOne.updateOrientation(Direction.down);
    } else if (e.logicalKey == LogicalKeyboardKey.escape) {
      if (isPaused) {
        removeWidgetOverlay('pauseMenu');
        game.resume();
      } else {
        pause(mode: PauseMode.pause);
      }
    } else if (e.logicalKey == LogicalKeyboardKey.keyL) miniMap();
  }

  void dispose() {
    _backgroundMusic?.stop();
    _backgroundMusic?.dispose();
    gamepad?.removeListener();
    game = null;
  }
}
