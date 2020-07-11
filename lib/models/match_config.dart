import 'package:xeonjia/models/game_mode.dart';

// Match parameters
class MatchConfig {
  final GameMode mode;
  final int teamSize;
  final int maxTime;
  final int maxPoints;
  final int mapId;
  final int difficulty;
  final bool friendlyFire;

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
