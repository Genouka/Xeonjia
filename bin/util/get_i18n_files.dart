import 'dart:io';
import 'package:path/path.dart';

import '../update_po_files.dart';
import 'translation.dart';

// fileName : <lang : list of translations>
Map<String, Map<String, List<Translation>>> getCurrentTranslations(
    {bool usePoFilename = false}) {
  var localeDir = Directory('locale');
  final exp = RegExp(r'#: (.*):\nmsgid "(.*)"\nmsgstr "([^"]*)"');
  var i18nFiles = <String, Map<String, List<Translation>>>{};
  localeDir.listSync().forEach((locale) {
    var lang = locale.path.split('/').last;
    if (lang == 'template') return;
    var messagesDir = Directory(locale.path + '/LC_MESSAGES');
    messagesDir.listSync().forEach((poFile) {
      if (poFile is File) {
        var content = poFile.readAsStringSync();
        metadata[poFile.path] =
            RegExp(r'(.*?)\n\n#: ', dotAll: true).firstMatch(content).group(1);
        content = content.replaceAll('"\n"', ''); // Remove multiline strings
        exp.allMatches(content).forEach((match) {
          var fileName = usePoFilename
              ? basenameWithoutExtension(poFile.path)
              : match.group(1);
          var msgid = match.group(2);
          var msgstr = match.group(3);
          if (msgstr.isEmpty) return;
          var translation = Translation(match.group(1), msgid, msgstr);
          if (i18nFiles.containsKey(fileName)) {
            i18nFiles[fileName].containsKey(lang)
                ? i18nFiles[fileName][lang].add(translation)
                : i18nFiles[fileName][lang] = [translation];
          } else {
            i18nFiles[fileName] = {
              lang: [translation]
            };
          }
        });
      }
    });
  });
  return i18nFiles;
}
