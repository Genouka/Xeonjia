import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/character.dart';
import 'package:xeonjia/src/screens/game/game_page.dart';
import 'package:xeonjia/src/screens/game/utils/map_utils.dart';
import 'package:xeonjia/src/util/local_data_controller.dart';

// Main game variable
XeonjiaGame game;

// Main character
CharacterComponent playerOne;

// Default component dimension
double componentSize;

// Time between each cycle of update
// Frequency = (1 / updatePeriod)
const double updatePeriod = 0.03;

// Default distance made at each frame update
// Component speed depend on this value and on updatePeriod value
// It equals to componentSize / 4
// Movements don't depend on the time that has been passed between 2 update()...
double defaultDistancePerFrame;

// Xeonjia game class
class XeonjiaGame extends BaseGame {
  // Game mode
  final GameMode mode;

  // Game start date
  double startDate;

  // Time elapsed since last time components have been updated
  double timeSinceUpdate;

  // If true, game is paused so no one can move
  bool pause;

  // Map size
  int mapHeight;
  int mapWidth;

  // List of CharacterComponent in game
  List<CharacterComponent> players = [];

  // Number of players for each team
  int teamSize;

  // List of teams
  final List<Team> teams = [
    Team(id: 0, name: 'Team A', color: Colors.red),
    Team(id: 1, name: 'Team B', color: Colors.blue)
  ];

  XeonjiaGame(this.mode, {this.teamSize}) {
    initialize();
  }

  // Reset variables and import map data
  void initialize() {
    pause = true;

    // Reset variables
    timeSinceUpdate = 0;
    startDate = currentTime();

    // Remove previous components
    // They are removed during the next update()
    components.forEach((component) {
      (component as BasicComponent).remove = true;
    });
    playerOne = null;

    // Import map and components
    String _map = (mode == GameMode.story)
        ? mainCharacter.visitedRooms.last.toString().padLeft(3, '0')
        : 'arena/1';
    importMap('assets/maps/' + _map + '.tmx');

    // Reset top and bottom bars
    lifePointsBar.state.refresh(percent: 1, text: 'LP: Max', poison: false);
    weaponBar.state.refresh(percent: 1, text: 'Punch');

    pause = false;
  }

  @override
  void update(double t) {
    if (!pause) {
      // Update components for each updatePeriod elapsed since last game.update
      for (timeSinceUpdate += t;
          timeSinceUpdate >= updatePeriod;
          timeSinceUpdate -= updatePeriod) {
        components.forEach((c) => c.update(t));
        components.removeWhere((c) => c.destroy());
      }
    }
  }

  // Save match data and load the new room
  void changeRoom(int nextRoomId) {
    game.pause = true;

    bool _levelUp = false;
    bool _isNewRoom = true;

    // Save new player data into mainCharacter
    mainCharacter.killedComponents += playerOne.killedEnemies;
    mainCharacter.doorKeyList.addAll(playerOne.doorKeyList);
    mainCharacter.objectList.addAll(playerOne.objectList);
    mainCharacter.minutesPlayed += (game.currentTime() - game.startDate) / 60;
    mainCharacter.movesCounter += playerOne.movesCounter;

    // If the room hasn't been already visited, increase exp points and money
    for (int i = 0; i < mainCharacter.visitedRooms.length - 1; i++) {
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
    game.initialize();
  }

  // Manage drag gestures
  void gestureDragInput(Offset delta) {
    playerOne?.updateDirection(delta.dx, delta.dy);
  }

  // Manage tap gesture
  void gestureTapInput(Offset position) {
    // Do nothing if pause or if tapping on top bar
    if (pause || position.dy < 40) return;

    // Do not update orientation if tapping on bottom bar
    if (position.dy <= screenDimensions.height + 40) {
      double _relativeTapX =
          position.dx - (playerOne.x + componentSize / 2 - camera.x);
      double _relativeTapY =
          position.dy - (playerOne.y + componentSize / 2 - camera.y) - 40;

      // Update character orientation
      if (position.dx < componentSize ||
          position.dx > screenDimensions.width - componentSize) {
        playerOne.updateOrientation(position.dx - componentSize, 0);
      } else if (position.dy - 40 < componentSize ||
          position.dy > screenDimensions.height - componentSize) {
        playerOne.updateOrientation(0, position.dy - 40 - componentSize);
      } else if (_relativeTapX.abs() > 15 || _relativeTapY.abs() > 15) {
        if (_relativeTapX.abs() > _relativeTapY.abs()) {
          playerOne.updateOrientation(_relativeTapX, 0);
        } else {
          playerOne.updateOrientation(0, _relativeTapY);
        }
      }
    }

    // Use weapon selected by player
    playerOne.selectedWeapon.shoot(shooter: playerOne);
  }

  // Update camera position
  void updateCamera(double x, double y) {
    // Update x position
    if (x <= screenDimensions.width / 2 ||
        screenDimensions.width > componentSize * mapWidth) {
      game.camera.x = 0.0;
    } else if (x > componentSize * mapWidth - screenDimensions.width / 2) {
      game.camera.x = componentSize * mapWidth - screenDimensions.width;
    } else {
      game.camera.x = x - screenDimensions.width / 2;
    }
    // Update y position
    if (y <= screenDimensions.height / 2 ||
        screenDimensions.height > componentSize * mapHeight) {
      game.camera.y = 0.0;
    } else if (y > componentSize * mapHeight - screenDimensions.height / 2) {
      game.camera.y = componentSize * mapHeight - screenDimensions.height;
    } else {
      game.camera.y = y - screenDimensions.height / 2;
    }
  }

  // End game, function called if player one lose
  void end() {
    pause = true;
    mainCharacter.minutesPlayed += (game.currentTime() - game.startDate) / 60;
    mainCharacter.movesCounter += playerOne.movesCounter;
    ++mainCharacter.deathCounter;
    mainCharacter.money -= mainCharacter.visitedRooms.last * 10;
    if (mainCharacter.money < 0) mainCharacter.money = 0;
    saveUserData();
    endDialog();
  }

  // Dialog displayed if player one loose
  void endDialog() {
    showDialog(
        context: gameContext,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
            onWillPop: () => null,
            child: AlertDialog(
              title: const Text('You have been deleted'),
              content: const Text('Do you want to restart this game?'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    initialize();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                    game = null;
                    // Re-enable system bars before exit
                    SystemChrome.setEnabledSystemUIOverlays(
                        SystemUiOverlay.values);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )));
  }
}

// Team used in multi-player match
// It is composed by 2-5 players
class Team {
  // Team id
  final int id;

  // Team name
  final String name;

  // Team color
  final Color color;

  // Team members
  List<CharacterComponent> get members =>
      game.players.where((player) => player.team == id);

  // Team points
  int get points {
    int _points = 0;
    members.forEach((member) {
      _points += member.points;
    });
    return _points;
  }

  Team({@required this.id, this.name = 'Team', this.color = Colors.blue});
}
