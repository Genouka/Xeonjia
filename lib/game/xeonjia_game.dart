import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/components/background.dart';
import 'package:xeonjia/game/components/character.dart';
import 'package:xeonjia/game/components/common/basic.dart';
import 'package:xeonjia/game/components/modifer.dart';
import 'package:xeonjia/game/models/game_map.dart';
import 'package:xeonjia/game/models/team.dart';
import 'package:xeonjia/game/utils/direction.dart';
import 'package:xeonjia/game/utils/event_manager.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/utils/little_scheme.dart';
import 'package:xeonjia/game/utils/map_importer.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/utils/message_manager.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/utils/wireless_gamepad.dart';
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
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

// Default component speed (componentSize per second)
double get defaultSpeed => componentSize * 8;

// Default component dimension
late double componentSize;

// Xeonjia game class
class XeonjiaGame extends FlameGame
    with KeyboardEvents, PanDetector, SingleGameInstance, TapDetector {
  XeonjiaGame(this.config) {
    environment = setEnvironment(this);
    messageManager = MessageManager(this);
    dialogBox = DialogBox(this);
    _statusBox = StatusBox(this);
    _virtualGamePad = VirtualGamePad(this);
    overlayMap = {
      'statusBox': (BuildContext context, XeonjiaGame game) {
        return _statusBox;
      },
      'backpackButton': (BuildContext context, XeonjiaGame game) {
        return BackpackButton(game);
      },
      'backpackMenu': (BuildContext context, XeonjiaGame game) {
        return BackpackMenu(game);
      },
      'noMapsMenu': (BuildContext context, XeonjiaGame game) {
        return NoMapsMenu(game, '43');
      },
      'miniMapButton': (BuildContext context, XeonjiaGame game) {
        return MiniMapButton(game, miniMapIsActive: game.miniMapActive);
      },
      'virtualGamePad': (BuildContext context, XeonjiaGame game) {
        return _virtualGamePad;
      },
      'dialogBox': (BuildContext context, XeonjiaGame game) {
        return game.dialogBox;
      },
    };
    overlays.add('statusBox');
    overlays.add('virtualGamePad');
    overlays.add('dialogBox');
    initGamepad();
    if (settings.backgroundMusic && config.mode == GameMode.story) {
      _backgroundMusic = Bgm();
      _backgroundMusic!.initialize();
    }
    if (config.mode == GameMode.story) {
      miniMapActive = false;
      overlays.add('miniMapButton');
      overlays.add('backpackButton');
    } else {
      teams = [
        Team(this, id: 0, name: 'Team A', color: Colors.red),
        Team(this, id: 1, name: 'Team B', color: Colors.green),
      ];
    }
    start();
  }

  // Vertical offset used to translate characters
  double get characterOffset =>
      -(componentSize * (miniMapEnabled ? camera.zoom : 1) / 8)
          .gridAligned
          .toDouble();

  // Match settings
  final MatchConfig config;

  // Map with widgets overlay
  Map<String, Widget Function(BuildContext, XeonjiaGame)>? overlayMap;
  void addCustomWidgetOverlay(String overlayName, Widget widget) {
    overlayMap![overlayName] = (BuildContext context, XeonjiaGame game) {
      return widget;
    };
    overlays.add(overlayName);
  }

  // Scheme's environment
  late Environment environment;

  // Dialog box
  late DialogBox dialogBox;
  late MessageManager messageManager;

  // Box with lifePoints, pause, time and team points
  late StatusBox _statusBox;

  // Virtual Gamepad (D-pad + buttons)
  late VirtualGamePad _virtualGamePad;

  // Timer used in multiplayer mode
  Timer? _timer;
  int elapsedSeconds = 0;
  int get remainingTime => config.maxTime - elapsedSeconds;

  // If true the game is paused
  bool _pause = false;
  bool get isPaused => _pause;
  bool get isNotPaused => !_pause;

  // Map properties
  late GameMap map;

  // Current event log
  // It is synced with mainCharacter.eventLog while changing room
  late Map<String, dynamic> currentEventLog;

  // List of CharacterComponent in game
  List<CharacterComponent> players = [];
  List<BasicComponent> deletedComponents = [];

  // Main character
  CharacterComponent? playerOne;

  // List of teams
  List<Team>? teams;

  @override
  Future<void>? add(Component component) {
    if (component is CharacterComponent) {
      players.add(component);
      if (component.tile.properties['isPlayerOne'] ?? false) {
        playerOne = component;
      }
    }
    return super.add(component);
  }

  // Get component from ID
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

  // Count enemies in the room
  int get enemies => children
      .where((e) =>
          (e is BasicComponent &&
              [-3, -2, 1].contains(e.teamId) &&
              !e.deleted) ||
          (e is CharacterComponent && e.friendly == false && !e.deleted))
      .length;

  // List of teams sorted by points
  List<Team> get ranking {
    var list = List.from(teams!).cast<Team>();
    list.sort((a, b) => b.points.compareTo(a.points));
    return list;
  }

  // List of modifier to be regenerate during the next regenerateModifiers()
  List<ModifierComponent> modifiersToBeRegenerated = [];

  // Wireless gamepad
  FlameGamepad? gamepad;

  // Background music
  Bgm? _backgroundMusic;
  String? currentBgm;

  @override
  Color backgroundColor() => const Color(0xFF5D6872);

  // Reset variables and import map data
  void start() async {
    pause(stopMusic: false);
    overlays.remove('mapNameBox');
    overlays.remove('miniMapButton');
    overlays.remove('backpackButton');

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    elapsedSeconds = 0;

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
        overlays.remove('loading');
        _backgroundMusic?.dispose();
        overlays.add('noMapsMenu');
        return;
      }
      await importMap(this, 'assets/maps/story/${map.id}.tmx');
      miniMapActive = false;
      overlays.add('miniMapButton');
      overlays.add('backpackButton');
    } else {
      map = GameMap(fullId: config.mapId.toString());
      await importMap(this, 'assets/maps/arena/${config.mapId}.tmx');
    }

    _timer = Timer(1, repeat: true, onTick: () {
      if (isPaused) return;
      elapsedSeconds++;
      if (config.mode != GameMode.story) {
        if (elapsedSeconds == config.maxTime) end(timeOut: true);
        if (elapsedSeconds % 10 == 0) regenerateModifiers();
        _statusBox.state?.refresh();
      }
    });
    _timer?.start();

    if (isLoaded) update(0);
    resume();
    playBackgroundMusic();
  }

  @override
  void update(double dt) {
    _timer?.update(dt);
    super.update(dt);
  }

  @override
  Future<void>? onLoad() {
    update(0);
    return null;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    componentSize =
        (canvasSize.toSize().longestSide / 16).round16.gridAligned.toDouble();
    camera.zoom = 1;
    updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
  }

  // Pause game
  void pause({PauseMode? mode, bool stopMusic = true, bool stopEngine = true}) {
    if (_pause) return;
    _pause = true;
    if (stopEngine) pauseEngine();
    if (stopMusic) _backgroundMusic?.pause();
    if (mode != null) {
      addCustomWidgetOverlay('pauseMenu', PauseMenu(this, mode));
    }
  }

  // Resume game
  void resume() {
    _pause = false;
    resumeEngine();
    _backgroundMusic?.resume();
  }

  // Execute an action
  void executeAction(
      {required String? action, BasicComponent? actor, BasicComponent? self}) {
    if (action?.isEmpty ?? true) return;
    pause(stopEngine: false, stopMusic: false);
    environment.defineSymbol(
        Sym('self'), Intrinsic('self', 0, (Cell? x) => self!));
    environment.defineSymbol(Sym('actor'), actor ?? playerOne!);
    _actionContinuation =
        evaluate(readFromTokens(splitStringIntoTokens(action!)), environment);
  }

  // Continue action execution after (wait)
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
        onTick: () => evaluate(null, environment, _actionContinuation!),
      ));
    } else {
      resume();
    }
  }

  // Show a message in messageBox
  void setMessage(Message? message, {bool? hideMap}) {
    if (message != null) setMessages([message], hideMap: hideMap ?? false);
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
      _backgroundMusic?.play('bgm/' + currentBgm!);
    });
  }

  // Play sound effect
  void playSound(Sfx sfx) {
    if (settings.soundEffects) FlameAudio.play(sfx.fileName, volume: 0.3);
  }

  // Save match data and load the new room
  void changeRoom(String nextRoomId, {bool enterNextRoom = true}) {
    pause(stopMusic: false);
    if (enemies == 0) {
      currentEventLog['${map.id}-safe'] = true;
    }

    // Save new player data into mainCharacter
    mainCharacter.def = playerOne!.def;
    mainCharacter.maxLifePoints = playerOne!.maxLifePoints;
    mainCharacter.currentLifePoints = playerOne!.lifePoints;
    mainCharacter.money = playerOne!.money;
    mainCharacter.defeatedComponents += playerOne!.defeatedEnemies;
    mainCharacter.minutesPlayed += elapsedSeconds / 60;
    mainCharacter.movesCounter += playerOne!.movesCounter;
    mainCharacter.visitedRooms.add(nextRoomId);
    mainCharacter.eventLog = Map.from(currentEventLog);
    mainCharacter.itemList = List.from(playerOne!.itemList);
    mainCharacter.weaponList = List.from(playerOne!.weaponList);
    mainCharacter.selectedWeaponIndex = playerOne!.selectedWeaponIndex;
    saveUserData();

    // Load the next room
    if (enterNextRoom) start();
  }

  // Regenerate regenerable modifiers
  void regenerateModifiers() {
    for (final modifier in modifiersToBeRegenerated) {
      modifier.deleted = false;
      add(modifier);
    }
    modifiersToBeRegenerated.clear();
  }

  // Update camera position
  void updateCamera(double x, double y) {
    if (map.width == 0) return;
    camera.snapTo(Vector2(
        _moveCamera(size.x, map.width, x), _moveCamera(size.y, map.height, y)));
  }

  // Calculate camera position
  double _moveCamera(double screenSize, int mapSize, double pos) {
    var delta = mapSize * componentSize - screenSize;
    return (delta <= 0 ? delta / 2 : max(0, min(pos - screenSize / 2, delta)))
        .gridAligned
        .toDouble();
  }

  // Mini-map
  bool miniMapEnabled = false;
  bool miniMapActive = false;

  // Enable/Disable mini-map view
  void miniMap() {
    miniMapEnabled = !miniMapEnabled;
    if (miniMapEnabled) {
      zoomMiniMap(toValue: camera.zoom, enable: true);
      pause(stopEngine: false, stopMusic: false);
      _statusBox.state?.refresh();
      overlays.remove('mapNameBox');
      addCustomWidgetOverlay('mapNameBox', MapNameBox(this));
      overlays.remove('miniMapButton');
      overlays.remove('backpackButton');
      refreshWeaponButtons();
      miniMapActive = true;
    } else {
      updateCamera(playerOne!.x, playerOne!.y);
      overlays.remove('mapNameBox');
      overlays.remove('miniMapButton');
      overlays.add('backpackButton');
      refreshWeaponButtons();
      _statusBox.state?.refresh();
      resume();
      miniMapActive = false;
    }
    overlays.add('miniMapButton');
  }

  // Change mini-map zoom
  void zoomMiniMap({double? toValue, bool out = false, bool enable = false}) {
    var previousValue = enable ? 1 : camera.zoom;
    var delta = 16 / componentSize;
    var miniMapZoom = toValue ??
        (out
            ? max(previousValue - delta, delta)
            : min(previousValue + delta, 2));
    camera.zoom =
        (playerOne!.size.x * miniMapZoom).gridAligned / (playerOne!.size.x);
    updateCamera(playerOne!.x, playerOne!.y);
  }

  // Open backpack
  void backpack() {
    pause(stopMusic: false);
    overlays.add('backpackMenu');
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
    if (teams!.first.points >= config.maxPoints ||
        teams!.last.points >= config.maxPoints) {
      end();
    }
  }

  // End of the game (defeat in single player or end match in multiplayer)
  void end({bool timeOut = false}) {
    pause();
    int? lostMoney;
    if (config.mode == GameMode.story) {
      mainCharacter.minutesPlayed += elapsedSeconds / 60;
      mainCharacter.movesCounter += playerOne!.movesCounter;
      ++mainCharacter.defeatsCounter;
      mainCharacter.currentLifePoints = playerOne!.maxLifePoints;
      lostMoney = mainCharacter.visitedRooms.toSet().length;
      mainCharacter.money -= lostMoney;
      if (mainCharacter.money < 0) mainCharacter.money = 0;
      saveUserData();
    }
    refreshLifePointsBar();
    addCustomWidgetOverlay('endMenu', EndMenu(this, lostMoney ?? 0));
  }

  Offset? _panGestureOffset;

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!_pause &&
        (info.raw.delta.dx.abs() > 5 || info.raw.delta.dy.abs() > 5)) {
      _panGestureOffset = info.raw.delta.dx.abs() > info.raw.delta.dy.abs()
          ? Offset(info.raw.delta.dx, 0)
          : Offset(0, info.raw.delta.dy);
      playerOne?.updateOrientation(GetDirection.fromOffset(_panGestureOffset!));
    } else if (miniMapEnabled) {
      camera.snapTo(Vector2(
          _moveCamera(size.x, map.width,
              camera.position.x - info.raw.delta.dx + size.x / 2),
          camera.position.y = _moveCamera(size.y, map.height,
              camera.position.y - info.raw.delta.dy + size.y / 2)));
    }
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onPanEnd(DragEndInfo _) {
    if (_panGestureOffset != null) {
      gestureDragInput(GetDirection.fromOffset(_panGestureOffset!));
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    messageManager.active
        ? dialogBox.state!.next()
        : gestureTapInput(info.raw.globalPosition);
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
    var relativeTapX =
        position.dx - (playerOne!.x + componentSize / 2 - camera.position.x);
    var relativeTapY =
        position.dy - (playerOne!.y + componentSize / 2 - camera.position.y);

    if (position.dx < componentSize || position.dx > size.x - componentSize) {
      playerOne!.updateOrientation(
          GetDirection.fromXY(position.dx - componentSize, 0));
    } else if (position.dy < componentSize ||
        position.dy > size.y - componentSize) {
      playerOne!.updateOrientation(
          GetDirection.fromXY(0, position.dy - componentSize));
    } else if (relativeTapX.abs() > 15 || relativeTapY.abs() > 15) {
      relativeTapX.abs() > relativeTapY.abs()
          ? playerOne!.updateOrientation(GetDirection.fromXY(relativeTapX, 0))
          : playerOne!.updateOrientation(GetDirection.fromXY(0, relativeTapY));
    }

    // Use weapon selected by player
    playerOne!.shoot();
  }

  // Handle back button
  Future<bool> onWillPop() {
    miniMapEnabled ? miniMap() : pause(mode: PauseMode.exit);
    return Future.value(false);
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      gestureDragInput(Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      gestureDragInput(Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      gestureDragInput(Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      gestureDragInput(Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      playerOne!.shoot();
    } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
      playerOne!.updateOrientation(Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      playerOne!.updateOrientation(Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      playerOne!.updateOrientation(Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      playerOne!.updateOrientation(Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (isPaused) {
        overlays.remove('pauseMenu');
        resume();
      } else {
        pause(mode: PauseMode.pause);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
      miniMap();
    }
    return KeyEventResult.handled;
  }

  void dispose() {
    _backgroundMusic?.stop();
    _backgroundMusic?.dispose();
    _backgroundMusic = null;
    gamepad?.removeListener();
  }
}
