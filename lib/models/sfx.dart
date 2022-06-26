// Sound effects (file name is equal to the enum name)
enum Sfx { collision, item, punch, snowball, explosion, dialog }

extension SfxFileName on Sfx {
  String get fileName => 'sfx/$name.oga';
}
