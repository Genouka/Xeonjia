import 'dart:io';
import 'package:path/path.dart';

import 'translation.dart';

// Map <file path (.tmx | .tsx) : [...msgids]>
Map<String, List<Translation>> tmx2po() {
  // Find dialogs or map-names
  final regexGlobal = RegExp(
      r"\(dialog[\n ]+'\((.*?)\)\)\)|\(map-name[\n ]+(.*?)\)",
      dotAll: true);

  // Find text inside dialog or map-name
  final regexText = RegExp(r'(?:&quot;(.*)&quot; )?(?:&quot;(.*)&quot;)+');

  // Find the author of the message
  final regexAuthorName = RegExp(r'([^\/]*)\/?([^_]*)_?(.*)');

  // Map directory : list of strings
  var dirStringsMap = <String, List<Translation>>{};
  const mapsPath = 'assets/maps/';
  var mapsDir = Directory(mapsPath);
  mapsDir.listSync(recursive: true).forEach((fsEntity) {
    if (fsEntity is File &&
        ['.tmx', '.tsx'].contains(extension(fsEntity.path))) {
      var dir = RegExp('$mapsPath(.*)/.*').firstMatch(fsEntity.path)?.group(1);
      var content = fsEntity.readAsStringSync();
      regexGlobal.allMatches(content).forEach((match) {
        regexText.allMatches(match.group(0)).forEach((text) {
          var string = Translation(fsEntity.path, text.group(2), null);
          var author = text.group(1);
          Translation authorName;
          if (author != null) {
            authorName = Translation(fsEntity.path,
                regexAuthorName.firstMatch(author).group(1), null);
          }
          if (!dirStringsMap.containsKey(dir)) dirStringsMap[dir] = [];
          if (string.msgid != null &&
              string.msgid != '' &&
              dirStringsMap[dir].every((element) => element != string)) {
            dirStringsMap[dir].add(string);
          }
          if (authorName?.msgid != null &&
              authorName.msgid != '' &&
              dirStringsMap[dir].every((element) => element != authorName)) {
            dirStringsMap[dir].add(authorName);
          }
        });
      });
    }
  });
  return dirStringsMap;
}
