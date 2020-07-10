import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/components/dynamic/character.dart';
import 'package:xeonjia/game/components/static/modifer.dart';
import 'package:xeonjia/game/util/gamepad.dart';
import 'package:xeonjia/game/util/map_utils.dart';
import 'package:xeonjia/models/direction.dart';
import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/team.dart';
import 'package:xeonjia/ui/screens/game/widgets/info_box.dart';
import 'package:xeonjia/ui/screens/game/widgets/message_box.dart';
import 'package:xeonjia/ui/screens/game/widgets/virtual_gamepad.dart';
import 'package:xeonjia/util/local_data_controller.dart';
import 'package:xeonjia/util/screen_dimension.dart';

// Main game variable
XeonjiaGame game;

// Main character
CharacterComponent playerOne;

// Timer used in multiplayer games
Timer timer;

// Time between each cycle of update
// Frequency = (1 / updatePeriod)
const double updatePeriod = 0.03;

// Default component dimension
double componentSize;

// Default distance made at each frame update
// Component speed depend on this value and on updatePeriod value
// Movements don't depend on the time that has been passed between 2 update()...
double defaultDistancePerFrame;

// Xeonjia game class
class XeonjiaGame extends BaseGame with PanDetector, TapDetector {
  // Game mode
  final GameMode mode;

  // Number of players for each team
  final int teamSize;

  // If true, players can hit their teammates
  final bool friendlyFire;

  // Points required to win in multiplayer
  final int maxPoints;

  // Max game time in multiplayer mode (seconds)
  final int maxTime;

  // Multiplayer match difficulty
  final int difficulty;

  // Map to load if mode != story
  final int mapId;

  // Message box
  final messageBox = MessageBox();

  // Box with lifePoints, pause, time and team points
  final _infoBox = InfoBox();

  // Game dialogs
  final VoidCallback pauseDialog;
  final Function endDialog;

  // Game start date
  double startDate;

  // Time elapsed since last time components have been updated
  double timeSinceUpdate;

  // If true, game is paused so no one can move
  bool _pause;

  // Map size
  int mapHeight;
  int mapWidth;

  // Screen height minus points bar
  double fixedScreenHeight;

  // List of CharacterComponent in game
  List<CharacterComponent> players = [];

  // List of teams
  List<Team> teams;

  // Remaining time (used in multiplayer games)
  int remainingTime;

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

  // Variable used to avoid exit when gamepad B button is pressed
  bool avoidExit = false;

  XeonjiaGame(
    this.mode, {
    this.teamSize = 0,
    this.friendlyFire = false,
    this.maxPoints = 1500,
    this.maxTime = 180,
    this.difficulty = 4,
    this.mapId = 0,
    @required this.pauseDialog,
    @required this.endDialog,
  }) {
    initialize();
  }

  @override
  Widget get widget => Stack(
        children: <Widget>[
          super.widget,
          messageBox,
          _infoBox,
          if (settings.inputMethod != 0)
            VirtualGamepad(manageMovements: settings.inputMethod == 1),
        ],
      );

  @override
  Color backgroundColor() => const Color(0xFFE1F5FE);

  // Reset variables and import map data
  void initialize() {
    pause();

    // Reset variables
    timeSinceUpdate = 0;
    startDate = currentTime();

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
    var _map = (mode == GameMode.story)
        ? mainCharacter.visitedRooms.last.toString().padLeft(3, '0')
        : 'arena/$mapId';
    importMap('assets/maps/' + _map + '.tmx');

    initGamepad();

    if (mode != GameMode.story) startTimer();
    resume();
  }

  @override
  void update(double t) {
    // Update components for each updatePeriod elapsed since last game.update
    for (timeSinceUpdate += t;
        timeSinceUpdate >= updatePeriod;
        timeSinceUpdate -= updatePeriod) {
      super.update(t);
    }
  }

  // Pause game
  void pause() {
    _pause = true;
    pauseEngine();
  }

  // Resume game
  void resume() {
    _pause = false;
    resumeEngine();
  }

  // Start game timer
  void startTimer() {
    timer?.cancel();
    remainingTime = maxTime;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pause) return;
      if (--remainingTime <= 0) {
        timer.cancel();
        end(timeOut: true);
      } else if (teams.first.points >= maxPoints ||
          teams.last.points >= maxPoints) {
        end();
      } else if (remainingTime % 10 == 0) {
        regenerateModifiers();
      }
      _infoBox.state.refresh();
    });
  }

  // Save match data and load the new room
  void changeRoom(int nextRoomId) {
    pause();
    var _levelUp = false;
    var _isNewRoom = true;

    // Save new player data into mainCharacter
    mainCharacter.killedComponents += playerOne.killedEnemies;
    mainCharacter.doorKeyList.addAll(playerOne.doorKeyList);
    mainCharacter.objectList.addAll(playerOne.objectList);
    mainCharacter.minutesPlayed += (currentTime() - startDate) / 60;
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
    initialize();
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
    if (messageBox.state.message != null) {
      messageBox.state.dismiss();
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
    if (position.dy <= fixedScreenHeight + (mode != GameMode.story ? 80 : 40)) {
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
          position.dy > fixedScreenHeight - componentSize) {
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
    fixedScreenHeight = screenSize.height - (mode != GameMode.story ? 40 : 0);
    // Update x position
    if (x <= screenSize.width / 2 ||
        screenSize.width > componentSize * mapWidth) {
      camera.x = 0.0;
    } else if (x > componentSize * mapWidth - screenSize.width / 2) {
      camera.x = componentSize * mapWidth - screenSize.width;
    } else {
      camera.x = x - screenSize.width / 2;
    }
    // Update y position
    if (y <= fixedScreenHeight / 2 ||
        fixedScreenHeight > componentSize * mapHeight) {
      camera.y = 0.0;
    } else if (y > componentSize * mapHeight - fixedScreenHeight / 2) {
      camera.y = componentSize * mapHeight - fixedScreenHeight;
    } else {
      camera.y = y - fixedScreenHeight / 2;
    }
  }

  // Reload weapon bar
  void refreshWeaponBar() {}

  // Reload LP bar
  void refreshLifePointsBar() {
    _infoBox.state.refresh();
  }

  // End of the game
  void end({bool timeOut = false}) {
    pause();
    if (mode == GameMode.story) {
      mainCharacter.minutesPlayed += (currentTime() - startDate) / 60;
      mainCharacter.movesCounter += playerOne.movesCounter;
      ++mainCharacter.deathCounter;
      mainCharacter.money -= mainCharacter.visitedRooms.last * 10;
      if (mainCharacter.money < 0) mainCharacter.money = 0;
      saveUserData();
    }
    endDialog(timeOut: timeOut);
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
            avoidExit = true;
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
