import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

import 'translation.dart';

// Map <file name : [...msgids]>
Map<String, List<Translation>> tmx2po() {
  // Find dialogs or map-names
  final regexGlobal = RegExp(
      r"\((?:dialog|dialog-kobi)[\n ]+'\((.*?)\)\)\)|\((?:map-name|story-dialog)[\n ]+(.*?)\)",
      dotAll: true);

  // Find text inside dialog or map-name
  final regexText = RegExp('(?:&quot;(.*)&quot; )?(?:&quot;(.*)&quot;)+');

  // Find the author of the message
  final regexAuthorName = RegExp(r'([^\/]*)\/?([^_]*)_?(.*)');

  // Find npc-names
  final npcName = RegExp('property name="name" value="(.*?)"');

  // Find answers
  final regexAnswer = RegExp('(?:&quot;(.*?)&quot;)+');

  // Map directory : list of strings
  var dirStringsMap = <String, List<Translation>>{};
  const mapsPath = 'assets/maps/';
  var mapsDir = Directory(mapsPath);
  mapsDir.listSync(recursive: true).forEach((fsEntity) {
    if (fsEntity is File &&
        ['.tmx', '.tsx'].contains(extension(fsEntity.path))) {
      var name = 'story';
      var content = fsEntity.readAsStringSync();
      regexGlobal.allMatches(content).forEach((match) {
        regexText.allMatches(match.group(0)!).forEach((text) {
          var string = Translation(
              fsEntity.path,
              text
                  .group(2)!
                  .replaceAll(r'\&quot;', r'\"')
                  .replaceAll('&amp;', '&')
                  .replaceAll(r'*\', '*'),
              null);
          var author = text.group(1)?.replaceAll('&amp;', '&');
          Translation? authorName;
          if (author != null) {
            authorName = Translation(fsEntity.path,
                regexAuthorName.firstMatch(author)!.group(1)!, null);
          }
          if (!dirStringsMap.containsKey(name)) dirStringsMap[name] = [];
          if (string.msgid != '' &&
              dirStringsMap[name]!.every((element) => element != string)) {
            dirStringsMap[name]!.add(string);
          }
          if (authorName?.msgid != null &&
              authorName?.msgid != '' &&
              dirStringsMap[name]!.every((element) => element != authorName)) {
            dirStringsMap[name]!.add(authorName!);
          }
        });
      });
      npcName.allMatches(content).forEach((text) {
        var string = Translation(
            fsEntity.path, text.group(1)!.replaceAll('&amp;', '&'), null);
        if (!dirStringsMap[name]!.contains(string)) {
          dirStringsMap[name]!.add(string);
        }
      });
      RegExp(r'(\(answer .*\)\)\))').allMatches(content).forEach((text) {
        regexAnswer.allMatches(text[1]!).forEach((t) {
          var string = Translation(fsEntity.path, t[1]!, null);
          if (!dirStringsMap[name]!.contains(string)) {
            dirStringsMap[name]!.add(string);
          }
        });
      });
    }
  });
  var dataJsonFileName = 'assets/data/backpack-items.json';
  var data = json.decode(File(dataJsonFileName).readAsStringSync());
  data.forEach((_, value) {
    dirStringsMap['story']!
        .add(Translation(dataJsonFileName, value['name'], null));
    if (value['description'] != null) {
      dirStringsMap['story']!.add(Translation(dataJsonFileName,
          value['description'].replaceAll('\n', r'\n'), null));
    }
    if (value['action'] != null) {
      regexGlobal.allMatches(value['action']).forEach((match) {
        regexText
            .allMatches(match.group(0)!.replaceAll('"', '&quot;'))
            .forEach((text) {
          var string = Translation(
              dataJsonFileName,
              text
                  .group(2)!
                  .replaceAll(r'\&quot;', r'\"')
                  .replaceAll('&amp;', '&')
                  .replaceAll(r'*\', '*'),
              null);
          if (string.msgid != '' &&
              dirStringsMap['story']!.every((element) => element != string)) {
            dirStringsMap['story']!.add(string);
          }
        });
      });
    }
  });
  var mapsDataJsonFileName = 'assets/data/maps-data.json';
  var mapsData = json.decode(File(mapsDataJsonFileName).readAsStringSync());
  var added = [];
  mapsData.forEach((_, value) {
    if (value['text'] != null && !added.contains(value['text'])) {
      added.add(value['text']);
      dirStringsMap['story']!.add(Translation(
          dataJsonFileName, value['text'].replaceAll('\n', r'\n'), null));
    }
  });
  return dirStringsMap;
}
