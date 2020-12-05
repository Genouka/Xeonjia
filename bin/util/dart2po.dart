import 'dart:io';
import 'package:path/path.dart';

import 'translation.dart';

// Map <file path (.dart) : [...msgids]>
Map<String, List<Translation>> dart2po() {
  // Find dialogs or map-names
  final regexGlobal = RegExp(r"""('''|'|")(.*?)(?<!\\)\1(?:\n*\s*)(\.i18n)?""");

  // Map directory : list of strings
  var dirStringsMap = <String, List<Translation>>{};
  var mapsDir = Directory('lib');
  mapsDir.listSync(recursive: true).forEach((fsEntity) {
    if (fsEntity is File && extension(fsEntity.path) == '.dart') {
      var dir = RegExp('lib\/([^\/]*)\/.*').firstMatch(fsEntity.path)?.group(1);
      var content = fsEntity.readAsStringSync();
      regexGlobal.allMatches(content).forEach((match) {
        if (match.group(3) != null) {
          var string = Translation(fsEntity.path, match.group(2), null);
          if (!dirStringsMap.containsKey(dir)) dirStringsMap[dir] = [];
          if (string.msgid != null &&
              string.msgid != '' &&
              dirStringsMap[dir].every((element) => element != string)) {
            dirStringsMap[dir].add(string);
          }
        }
      });
    }
  });
  return dirStringsMap;
}
