import 'package:xeonjia/models/game_mode.dart';

// Match parameters
class MatchConfig {
  GameMode mode;
  int teamSize;
  int maxTime;
  int maxPoints;
  int mapId;
  int difficulty;
  bool friendlyFire;

  MatchConfig(
    this.mode, {
    this.teamSize = 0,
    this.maxTime = 0,
    this.maxPoints = 0,
    this.mapId = 0,
    this.difficulty = 0,
    this.friendlyFire = false,
  });
}
