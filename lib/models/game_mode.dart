// Game modes
enum GameMode {
  story('Story mode'),
  tdm('Team Deathmatch'),
  ctf('Capture the Flag');

  const GameMode(this.name);
  final String name;
}
