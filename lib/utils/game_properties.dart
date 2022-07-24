// Game modes
enum GameMode {
  story('Story mode'),
  tdm('Team Deathmatch'),
  ctf('Capture the Flag');

  const GameMode(this.name);
  final String name;
}

// Match parameters
class MatchConfig {
  MatchConfig(
    this.mode, {
    this.teamSize = 0,
    this.maxTime = 0,
    this.maxPoints = 0,
    this.mapId = 0,
    this.difficulty = 0,
    this.friendlyFire = false,
  });

  GameMode mode;
  int teamSize;
  int maxTime;
  int maxPoints;
  int mapId;
  int difficulty;
  bool friendlyFire;
}
