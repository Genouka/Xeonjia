import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/time.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/util/gamepad.dart';
import 'package:xeonjia/game/util/map_importer.dart';
import 'package:xeonjia/game/widgets_overlay/end_menu.dart';
import 'package:xeonjia/game/widgets_overlay/info_box.dart';
import 'package:xeonjia/game/widgets_overlay/dialog_box.dart';
import 'package:xeonjia/game/widgets_overlay/pause_menu.dart';
import 'package:xeonjia/game/widgets_overlay/virtual_gamepad.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/map_properties.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/util/screen_dimension.dart';

// Main game variable
XeonjiaGame game;

// Main character
CharacterComponent playerOne;

// Seconds between each cycle of update
const double updatePeriod = 0.03;

// Default distance traveled with each update
// Component speed depends on this and on updatePeriod
double defaultDistancePerUpdate;

// Default component dimension
double componentSize;

// Xeonjia game class
class XeonjiaGame extends BaseGame
    with HasWidgetsOverlay, PanDetector, TapDetector {
  // Match settings
  final MatchConfig config;

  XeonjiaGame(this.config) {
    init();
  }

  // Dialog box
  final _dialogBox = DialogBox();

  // Box with lifePoints, pause, time and team points
  final _infoBox = InfoBox();

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

  @override
  Color backgroundColor() => const Color(0xFF777777);

  // Reset variables and import map data
  void init() async {
    pause();

    // Import mainCharacter.eventLog
    currentEventLog = Map.from(mainCharacter.eventLog);

    // Reset variables
    timeSinceUpdate = 0;
    elapsedSeconds = 0;

    // Remove previous components
    // They are removed during the next update()
    components.forEach((component) {
      markToRemove(component);
    });
    playerOne = null;
    players.clear();

    teams = [
      Team(id: 0, name: 'Team A', color: Colors.red),
      Team(id: 1, name: 'Team B', color: Colors.green),
    ];
    modifiersToBeRegenerated.clear();

    // Import map and components
    var _map = (config.mode == GameMode.story)
        ? 'rooms/' + mainCharacter.visitedRooms.last.toString().padLeft(3, '0')
        : 'arena/${config.mapId}';
    await importMap('assets/maps/' + _map + '.tmx');

    setMessage(map.message);
    initGamepad();
    addWidgetOverlay('gamePad', VirtualGamePad());
    addWidgetOverlay('messageBox', _dialogBox);
    addWidgetOverlay('infoBox', _infoBox);

    _timer = Timer(1, repeat: true, callback: () {
      elapsedSeconds++;
      if (config.mode != GameMode.story) {
        if (elapsedSeconds == config.maxTime) end(timeOut: true);
        if (elapsedSeconds % 10 == 0) regenerateModifiers();
        _infoBox.state.refresh();
      }
    });
    _timer.start();
    resume();
  }

  @override
  void update(double dt) {
    _timer?.update(dt);
    // Update components for each updatePeriod elapsed since last game.update
    for (timeSinceUpdate += dt;
        timeSinceUpdate >= updatePeriod;
        timeSinceUpdate -= updatePeriod) {
      super.update(dt);
    }
  }

  @override
  void resize(Size size) {
    screenSize = size;
    updateCamera(playerOne?.x ?? 0, playerOne?.y ?? 0);
    super.resize(size);
  }

  // Pause game
  void pause({PauseMode mode}) {
    if (_pause ?? false) return;
    _pause = true;
    pauseEngine();
    if (mode != null) addWidgetOverlay('pauseMenu', PauseMenu(mode));
  }

  // Resume game
  void resume() {
    _pause = false;
    resumeEngine();
  }

  // Show a message in messageBox
  void setMessage(Message message) {
    if (message != null) setMessages([message]);
  }

  // Show a list of messages in messageBox
  void setMessages(List<Message> messages) {
    _dialogBox.state.setMessages(messages);
  }

  // Save match data and load the new room
  void changeRoom(int nextRoomId) {
    pause();
    var _levelUp = false;
    var _isNewRoom = true;

    // Save new player data into mainCharacter
    mainCharacter.killedComponents += playerOne.killedEnemies;
    mainCharacter.objectList = List.from(playerOne.objectList);
    mainCharacter.minutesPlayed += elapsedSeconds / 60;
    mainCharacter.movesCounter += playerOne.movesCounter;

    // If the room hasn't been already visited, increase exp points and money
    for (var i = 0; i < mainCharacter.visitedRooms.length - 1; i++) {
      if (mainCharacter.visitedRooms[i] == mainCharacter.visitedRooms.last &&
          mainCharacter.visitedRooms[i + 1] == nextRoomId) {
        _isNewRoom = false;
        break;
      }
    }
    if (_isNewRoom) {
      _levelUp =
          mainCharacter.expGained(playerOne.experiencePoints + nextRoomId);
      mainCharacter.money += playerOne.earnedMoney;
      mainCharacter.totalEarnedMoney += playerOne.earnedMoney;
    }

    mainCharacter.visitedRooms.add(nextRoomId);
    saveUserData();

    if (_levelUp) {
      // print('Level Up!');
    }

    // Start a new game
    init();
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
    // Do nothing if pause or if tapping on top bar
    if (_pause || position.dy < 40) return;

    // Update orientation if not tapping on bottom bar
    if (position.dy <=
        screenSize.height + (config.mode != GameMode.story ? 80 : 40)) {
      var _relativeTapX =
          position.dx - (playerOne.x + componentSize / 2 - camera.x);
      var _relativeTapY =
          position.dy - (playerOne.y + componentSize / 2 - camera.y) - 40;

      // Update character orientation
      if (position.dx < componentSize ||
          position.dx > screenSize.width - componentSize) {
        playerOne.updateOrientation(
            GetDirection.fromXY(position.dx - componentSize, 0));
      } else if (position.dy - 40 < componentSize ||
          position.dy > screenSize.height - componentSize) {
        playerOne.updateOrientation(
            GetDirection.fromXY(0, position.dy - 40 - componentSize));
      } else if (_relativeTapX.abs() > 15 || _relativeTapY.abs() > 15) {
        _relativeTapX.abs() > _relativeTapY.abs()
            ? playerOne.updateOrientation(GetDirection.fromXY(_relativeTapX, 0))
            : playerOne
                .updateOrientation(GetDirection.fromXY(0, _relativeTapY));
      }
    }

    // Use weapon selected by player
    playerOne.shoot();
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
    camera.x = min(max(0, x - screenSize.width / 2),
        componentSize * (map?.width ?? 0) - screenSize.width);
    camera.y = max(
        0,
        min(y - screenSize.height / 2,
            componentSize * (map?.height ?? 0) - screenSize.height));
  }

  // Reload weapon bar
  void refreshWeaponBar() {}

  // Reload LP bar
  void refreshLifePointsBar() {
    _infoBox.state.refresh();
  }

  // Check if someone won
  void checkMatchStatus() {
    if (teams.first.points >= config.maxPoints ||
        teams.last.points >= config.maxPoints) {
      end();
    }
  }

  // End of the game
  void end({bool timeOut = false}) {
    pause();
    if (config.mode == GameMode.story) {
      mainCharacter.eventLog = Map.from(currentEventLog);
      mainCharacter.minutesPlayed += elapsedSeconds / 60;
      mainCharacter.movesCounter += playerOne.movesCounter;
      ++mainCharacter.deathCounter;
      mainCharacter.money -= mainCharacter.visitedRooms.last * 10;
      if (mainCharacter.money < 0) mainCharacter.money = 0;
      saveUserData();
    }
    addWidgetOverlay('endMenu', EndMenu());
  }

  void dispose() {
    gamepad.removeListener();
    game = null;
  }

  // Initialize wireless gamepad listener
  void initGamepad() async {
    gamepad = FlameGamepad()
      ..setListener((evtType, key) {
        switch (key) {
          case GAMEPAD_DPAD_UP:
            gestureDragInput(Direction.up);
            break;
          case GAMEPAD_DPAD_DOWN:
            gestureDragInput(Direction.down);
            break;
          case GAMEPAD_DPAD_RIGHT:
            gestureDragInput(Direction.right);
            break;
          case GAMEPAD_DPAD_LEFT:
            gestureDragInput(Direction.left);
            break;
          case GAMEPAD_BUTTON_A:
            playerOne.shoot();
            break;
          case GAMEPAD_BUTTON_B:
            playerOne.shoot();
            break;
          case GAMEPAD_BUTTON_X:
            playerOne.shoot();
            break;
          case GAMEPAD_BUTTON_Y:
            playerOne.shoot();
            break;
          case GAMEPAD_BUTTON_L1:
            playerOne.nextWeapon();
            break;
          case GAMEPAD_BUTTON_L2:
            playerOne.nextWeapon();
            break;
          case GAMEPAD_BUTTON_R1:
            playerOne.nextWeapon();
            break;
          case GAMEPAD_BUTTON_R2:
            playerOne.nextWeapon();
            break;
          case GAMEPAD_BUTTON_START:
            break;
        }
      });
  }
}
