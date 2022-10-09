/// Sound effects
enum Sfx {
  collision,
  damage,
  dialog,
  explosion,
  gameover,
  item,
  money,
  punch,
  snowball,
  win,
}

extension SfxFileName on Sfx {
  String get fileName => 'sfx/$name.oga';
}
