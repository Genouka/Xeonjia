import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/components/abstract_basic.dart';
import 'package:xeonjia/src/screens/game/components/dynamic/character.dart';
import 'package:xeonjia/src/screens/game/components/static/modifer.dart';
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

// Timer used in multi-player games
Timer timer;

// Default distance made at each frame update
// Component speed depend on this value and on updatePeriod value
// It equals to componentSize / 4
// Movements don't depend on the time that has been passed between 2 update()...
double defaultDistancePerFrame;

// Xeonjia game class
class XeonjiaGame extends BaseGame with TapDetector, PanDetector {
  // Game mode
  final GameMode mode;

  // Number of players for each team
  final int teamSize;

  // If true, players can hit their teammates
  final bool friendlyFire;

  // Points required to win in multi-player
  final int maxPoints;

  // Max game time in multi-player mode (seconds)
  final int maxTime;

  // Map to load if mode != story
  final int mapId;

  // Game start date
  double startDate;

  // Time elapsed since last time components have been updated
  double timeSinceUpdate;

  // If true, game is paused so no one can move
  bool pause;

  // Map size
  int mapHeight;
  int mapWidth;

  // Screen height minus points bar
  double fixedScreenHeight;

  // List of CharacterComponent in game
  List<CharacterComponent> players = [];

  // List of teams
  List<Team> teams;

  // Remaining time (used in multi-player games)
  int _remainingTime;

  // List of teams sorted by points
  List<Team> get ranking {
    var list = List.from(teams).cast<Team>();
    list.sort((a, b) => b.points.compareTo(a.points));
    return list;
  }

  // List of modifier to be regenerate during the next regenerateModifiers()
  var modifiersToBeRegenerated = List<ModifierComponent>();

  XeonjiaGame(this.mode,
      {this.teamSize = 0,
      this.friendlyFire = false,
      this.maxPoints = 1500,
      this.maxTime = 180,
      this.mapId = 0}) {
    fixedScreenHeight = screenHeight - (mode != GameMode.story ? 40 : 0);
    initialize();
  }

  @override
  Color backgroundColor() => const Color(0xFFE1F5FE);

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
    players.clear();

    teams = [
      Team(id: 0, name: 'Team A', color: Colors.red),
      Team(id: 1, name: 'Team B', color: Colors.green)
    ];
    modifiersToBeRegenerated.clear();

    // Import map and components
    String _map = (mode == GameMode.story)
        ? mainCharacter.visitedRooms.last.toString().padLeft(3, '0')
        : 'arena/$mapId';
    importMap('assets/maps/' + _map + '.tmx');

    if (mode != GameMode.story) startTimer();
    pause = false;
  }

  @override
  void update(double t) {
    if (!pause) {
      // Update components for each updatePeriod elapsed since last game.update
      for (timeSinceUpdate += t;
          timeSinceUpdate >= updatePeriod;
          timeSinceUpdate -= updatePeriod) {
        super.update(t);
      }
    }
  }

  // Start game timer
  void startTimer() {
    timer?.cancel();
    _remainingTime = maxTime;
    if (multiPlayerBar.state.mounted) {
      multiPlayerBar.state.refresh(_remainingTime);
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (pause) return;
      if (--_remainingTime <= 0) {
        timer.cancel();
        end(timeOut: true);
      } else if (teams.first.points >= maxPoints ||
          teams.last.points >= maxPoints) {
        end();
      } else if (_remainingTime % 10 == 0) {
        regenerateModifiers();
      }
      if (multiPlayerBar.state.mounted) {
        multiPlayerBar.state.refresh(_remainingTime);
      }
    });
  }

  // Save match data and load the new room
  void changeRoom(int nextRoomId) {
    pause = true;
    bool _levelUp = false;
    bool _isNewRoom = true;

    // Save new player data into mainCharacter
    mainCharacter.killedComponents += playerOne.killedEnemies;
    mainCharacter.doorKeyList.addAll(playerOne.doorKeyList);
    mainCharacter.objectList.addAll(playerOne.objectList);
    mainCharacter.minutesPlayed += (currentTime() - startDate) / 60;
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
    initialize();
  }

  Offset _panGestureOffset;
  @override
  void onPanUpdate(DragUpdateDetails upd) {
    if (settings.inputMethod == 0 && !pause) {
      if (upd.delta.dx.abs() > 5 || upd.delta.dy.abs() > 5) {
        if (upd.delta.dx.abs() > upd.delta.dy.abs()) {
          _panGestureOffset = Offset(upd.delta.dx, 0);
        } else {
          _panGestureOffset = Offset(0, upd.delta.dy);
        }
        playerOne?.updateOrientation(
            _panGestureOffset.dx, _panGestureOffset.dy);
      }
    }
  }

  @override
  void onPanEnd(DragEndDetails end) {
    if (settings.inputMethod == 0 && !pause) {
      gestureDragInput(_panGestureOffset);
    }
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (settings.inputMethod == 0) {
      gestureTapInput(details.globalPosition);
    }
  }

  // Manage drag gestures
  void gestureDragInput(Offset delta) {
    playerOne?.updateDirection(delta.dx, delta.dy);
  }

  // Manage tap gesture
  void gestureTapInput(Offset position) {
    // Do nothing if pause or if tapping on top bar
    if (pause || position.dy < 40) return;

    // Update orientation if not tapping on bottom bar
    if (position.dy <= fixedScreenHeight + (mode != GameMode.story ? 80 : 40)) {
      double _relativeTapX =
          position.dx - (playerOne.x + componentSize / 2 - camera.x);
      double _relativeTapY =
          position.dy - (playerOne.y + componentSize / 2 - camera.y) - 40;

      // Update character orientation
      if (position.dx < componentSize ||
          position.dx > screenWidth - componentSize) {
        playerOne.updateOrientation(position.dx - componentSize, 0);
      } else if (position.dy - 40 < componentSize ||
          position.dy > fixedScreenHeight - componentSize) {
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
    // Update x position
    if (x <= screenWidth / 2 || screenWidth > componentSize * mapWidth) {
      camera.x = 0.0;
    } else if (x > componentSize * mapWidth - screenWidth / 2) {
      camera.x = componentSize * mapWidth - screenWidth;
    } else {
      camera.x = x - screenWidth / 2;
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
  void refreshWeaponBar() {
    weaponBar.state.refresh(
        percent: playerOne?.selectedWeapon?.powerPoints != double.infinity
            ? (playerOne?.selectedWeapon?.powerPoints ?? 100) /
                // should use max PP...
                (10 + 5 * playerOne?.selectedWeapon?.level)
            : 1,
        text: (playerOne?.selectedWeapon?.name ?? '') +
            (playerOne?.selectedWeapon?.powerPoints?.isFinite ?? false
                ? ' (${playerOne?.selectedWeapon?.powerPoints?.round().toString()})'
                : ''));
  }

  // Reload LP bar
  void refreshLifePointsBar() {
    double _percent = playerOne.lifePoints / playerOne.initialLifePoints;
    lifePointsBar.state.refresh(
      percent: _percent,
      text: 'LP: ' +
          (_percent.isFinite ? playerOne.lifePoints.round().toString() : 'Max'),
      poison: playerOne.poisonQuantity > 0,
    );
  }

  // End of the game
  void end({bool timeOut = false}) {
    pause = true;
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

  // Dialog displayed when the game ends
  void endDialog({bool timeOut}) {
    String title = '';
    String content = '';
    if (mode == GameMode.story) {
      title = 'You have been deleted';
    } else {
      title = 'Your team ' +
          (ranking.first.id == playerOne.teamId ? 'won' : 'lost');
      if (timeOut) {
        content = 'The time is over.';
      } else {
        content = '${maxPoints.toString()} points have been achieved.';
      }
    }
    content += '\n\nDo you want to restart this game?';

    showDialog(
        context: gameContext,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
            onWillPop: () => null,
            child: AlertDialog(
              title: Text(title),
              content: Text(content),
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
      game.players.where((player) => player.teamId == id).toList();

  // Team points acquired by friendly fire kills
  int basisPoints = 0;

  // Team points (basePoints + players points)
  int get points {
    int _points = 0;
    members.forEach((member) {
      _points += member.points;
    });
    return _points + basisPoints;
  }

  Team({@required this.id, this.name = 'Team', this.color = Colors.blue});
}
