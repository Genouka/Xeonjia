import 'dart:io';
import 'package:path/path.dart';

import 'translation.dart';

// Map <file name : [...msgids]>
Map<String, List<Translation>> dart2po() {
  // Find dialogs or map-names
  final regexGlobal = RegExp(r"""('''|'|")(.*?)(?<!\\)\1(?:\n*\s*)(\.i18n)?""");

  // Map directory : list of strings
  var dirStringsMap = <String, List<Translation>>{};
  var mapsDir = Directory('lib');
  mapsDir.listSync(recursive: true).forEach((fsEntity) {
    if (fsEntity is File && extension(fsEntity.path) == '.dart') {
      var name = 'ui';
      var content = fsEntity.readAsStringSync();
      regexGlobal.allMatches(content).forEach((match) {
        if (match.group(3) != null) {
          var string = Translation(
              fsEntity.path, match.group(2).replaceAll('"', '\\"'), null);
          if (!dirStringsMap.containsKey(name)) dirStringsMap[name] = [];
          if (string.msgid != null &&
              string.msgid != '' &&
              dirStringsMap[name].every((element) => element != string)) {
            dirStringsMap[name].add(string);
          }
        }
      });
    }
  });
  return dirStringsMap;
}
