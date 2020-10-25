// Game modes
enum GameMode { story, tdm, ctf }

extension GameModeInfo on GameMode {
  String get name {
    if (this == GameMode.story) return 'Story Mode';
    if (this == GameMode.tdm) return 'Team Deathmatch';
    return 'Capture the Flag';
  }
}
