import 'dart:async';
import 'dart:math';
import 'package:flame/bgm.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/util/event_manager.dart';
import 'package:xeonjia/game/util/map_importer.dart';
import 'package:xeonjia/game/util/wireless_gamepad.dart';
import 'package:xeonjia/game/widgets_overlay/end_menu.dart';
import 'package:xeonjia/game/widgets_overlay/info_box.dart';
import 'package:xeonjia/game/widgets_overlay/dialog_box.dart';
import 'package:xeonjia/game/widgets_overlay/loading_page.dart';
import 'package:xeonjia/game/widgets_overlay/pause_menu.dart';
import 'package:xeonjia/game/widgets_overlay/virtual_gamepad.dart';
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

// Xeonjia game class
class XeonjiaGame extends BaseGame
    with HasWidgetsOverlay, PanDetector, TapDetector {
  // Match settings
  final MatchConfig config;

  XeonjiaGame(this.config) {
    if (settings.backgroundMusic) {
      _backgroundMusic = Bgm();
      _backgroundMusic.initialize();
    }
    init();
  }

  // Scheme's environment
  final environment = setEnvironment();

  // Dialog box
  final _dialogBox = DialogBox();

  // Box with lifePoints, pause, time and team points
  final _statusBox = StatusBox();

  // Timer used in multiplayer mode
  Timer _timer;
  int elapsedSeconds = 0;
  int get remainingTime => config.maxTime - elapsedSeconds;

  // Time elapsed since last time components have been updated
  double timeSinceUpdate;

  // If true, game is paused so no one can move
  bool _pause;

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
  var modifiersToBeRegenerated = <ModifierComponent>[];

  // Wireless gamepad
  FlameGamepad gamepad;

  // Background music
  Bgm _backgroundMusic;
  String currentBgm;

  @override
  Color backgroundColor() => const Color(0xFF777777);

  // Reset variables and import map data
  void init() async {
    pause(stopMusic: false);
    addWidgetOverlay('loading', LoadingPage());
    removeWidgetOverlay('mapBox');

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    timeSinceUpdate = 0;
    elapsedSeconds = 0;
    playerOne = null;

    // Remove previous components
    // They are removed during the next update()
    components.forEach((component) {
      markToRemove(component);
    });
    players.clear();

    teams = [
      Team(id: 0, name: 'Team A', color: Colors.red),
      Team(id: 1, name: 'Team B', color: Colors.green),
    ];
    modifiersToBeRegenerated.clear();

    // Import map and components
    map = MapProperties(fullName: mainCharacter.visitedRooms.last);
    await importMap('assets/maps/' +
        ((config.mode == GameMode.story)
            ? 'story/' + map.name
            : 'arena/${config.mapId}') +
        '.tmx');

    initGamepad();
    addWidgetOverlay('gamePad', VirtualGamePad());
    addWidgetOverlay('messageBox', _dialogBox);
    addWidgetOverlay('statusBox', _statusBox);

    _timer = Timer(1, repeat: true, callback: () {
      elapsedSeconds++;
      if (config.mode != GameMode.story) {
        if (elapsedSeconds == config.maxTime) end(timeOut: true);
        if (elapsedSeconds % 10 == 0) regenerateModifiers();
        _statusBox.state.refresh();
      }
    });
    _timer.start();
    removeWidgetOverlay('loading');
    resume();
    playBackgroundMusic();

    if (map.action != null) {
      evaluate(readFromTokens(splitStringIntoTokens(map.action)), environment);
    }
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
  void pause({PauseMode mode, bool stopMusic = true}) {
    if (_pause ?? false) return;
    _pause = true;
    pauseEngine();
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
  void executeAction([String action]) {
    action ??= map.action ?? '';
    if (action == '') return;
    evaluate(readFromTokens(splitStringIntoTokens(action)), game.environment);
  }

  // Show a message in messageBox
  void setMessage(Message message, {bool hideMap}) {
    if (message != null) setMessages([message], hideMap: hideMap);
  }

  // Show a list of messages in messageBox
  void setMessages(List<Message> messages, {bool hideMap = false}) {
    _dialogBox.state.setMessages(messages, hideMap: hideMap);
  }

  // Start the background music
  void playBackgroundMusic() {
    if (!settings.backgroundMusic) return;
    var newBgm = map.music ?? 'town.ogg';
    if (newBgm == currentBgm) return;
    currentBgm = newBgm;
    _backgroundMusic.play('bgm/' + currentBgm);
  }

  // Start the background music
  void playSound(Sfx sfx) {
    if (!settings.soundEffects) return;
    Flame.audio.play(sfx.fileName, volume: 0.2);
  }

  // Save match data and load the new room
  void changeRoom(String nextRoomId) {
    pause(stopMusic: false);
    if (game.components
        .where((element) =>
            element is BasicComponent && [-3, -2, 1].contains(element.teamId))
        .isEmpty) currentEventLog['${map.name}-safe'] = true;

    // Save new player data into mainCharacter
    mainCharacter.level = playerOne.level;
    mainCharacter.atk = playerOne.atk;
    mainCharacter.def = playerOne.def;
    mainCharacter.lifePoints = playerOne.initialLifePoints;
    mainCharacter.currentLifePoints = playerOne.lifePoints;
    mainCharacter.killedComponents += playerOne.killedEnemies;
    mainCharacter.minutesPlayed += elapsedSeconds / 60;
    mainCharacter.movesCounter += playerOne.movesCounter;
    mainCharacter.money += playerOne.earnedMoney;
    mainCharacter.totalEarnedMoney += playerOne.earnedMoney;
    mainCharacter.visitedRooms.add(nextRoomId);
    mainCharacter.expGained(playerOne.experiencePoints +
        currentEventLog.length -
        mainCharacter.eventLog.length *
            mainCharacter.visitedRooms.toSet().length);
    mainCharacter.eventLog = Map.from(currentEventLog);
    mainCharacter.itemList = List.from(playerOne.itemList);
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
  void updateCamera(double x, double y) {
    if (map?.width == null) return;
    var _widthDiff = map.width * componentSize - screenSize.width;
    camera.x = _widthDiff <= 0
        ? _widthDiff / 2
        : min(max(0, x - screenSize.width / 2),
            componentSize * (map?.width ?? 0) - screenSize.width);

    var _heightDiff = map.height * componentSize - screenSize.height;
    camera.y = _heightDiff <= 0
        ? _heightDiff / 2
        : max(
            0,
            min(y - screenSize.height / 2,
                componentSize * map.height - screenSize.height));
  }

  // Reload weapon bar
  void refreshWeaponBar() {}

  // Reload LP bar
  void refreshLifePointsBar() {
    _statusBox.state.refresh();
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
      ++mainCharacter.deathCounter;
      mainCharacter.currentLifePoints = playerOne.initialLifePoints;
      lostMoney = mainCharacter.visitedRooms.toSet().length * 10;
      mainCharacter.money -= lostMoney;
      if (mainCharacter.money < 0) mainCharacter.money = 0;
      saveUserData();
    }
    addWidgetOverlay('endMenu', EndMenu(lostMoney));
  }

  Offset _panGestureOffset;

  @override
  void onPanUpdate(DragUpdateDetails upd) {
    if (settings.inputMethod != 1 &&
        !_pause &&
        (upd.delta.dx.abs() > 5 || upd.delta.dy.abs() > 5)) {
      _panGestureOffset = upd.delta.dx.abs() > upd.delta.dy.abs()
          ? Offset(upd.delta.dx, 0)
          : Offset(0, upd.delta.dy);
      playerOne?.updateOrientation(GetDirection.fromOffset(_panGestureOffset));
    }
  }

  @override
  void onPanEnd(DragEndDetails end) {
    if (settings.inputMethod != 1 && !_pause && _panGestureOffset != null) {
      gestureDragInput(GetDirection.fromOffset(_panGestureOffset));
    }
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (_dialogBox.state.active) {
      _dialogBox.state.next();
      return;
    }
    if (settings.inputMethod != 1) gestureTapInput(details.globalPosition);
  }

  // Manage drag gestures
  void gestureDragInput(Direction direction) {
    playerOne?.updateDirection(direction);
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

  void dispose() {
    _backgroundMusic?.dispose();
    gamepad.removeListener();
    game = null;
  }
}
