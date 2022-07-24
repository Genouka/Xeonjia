// Sound effects
enum Sfx { collision, item, punch, snowball, explosion, dialog }

extension SfxFileName on Sfx {
  String get fileName => 'sfx/$name.oga';
}
