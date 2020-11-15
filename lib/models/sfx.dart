import 'package:flutter/foundation.dart';

// Sound effects (file name is equal to the enum value)
enum Sfx { collision, item, punch, snowball, explosion, dialog }

extension SfxFileName on Sfx {
  String get fileName => 'sfx/${describeEnum(this)}.oga';
}
