// ignore_for_file: avoid_print
import 'dart:io';

import 'package:xeonjia/ui/screens/settings/resources/languages.dart';

import 'util/dart2po.dart';
import 'util/get_i18n_files.dart';
import 'util/tmx2po.dart';
import 'util/translation.dart';

final languageList = ['de', 'es', 'it', 'template'];
final appName = 'Xeonjia';
final author = 'DeepDaikon';
final year = '2020';

// Read each .dart, .tmx, .tsx file and re-generate .po files inside locales
// Use this command to run the script: flutter pub run bin/update_po_files
void main() {
  // filename : [...msgids]
  var dirStringsMap = <String, List<Translation>>{};
  dirStringsMap.addAll(dart2po());
  dirStringsMap.addAll(tmx2po());

  var currentTranslations = getCurrentTranslations();
  Directory('locales').listSync().forEach((f) => f.deleteSync(recursive: true));
  languageList.forEach((language) {
    dirStringsMap.forEach((fileName, strings) {
      var newPoFile = File('locales/$language/LC_MESSAGES/$fileName.po')
        ..createSync(recursive: true);
      newPoFile.writeAsStringSync('''
# ${languageName[language].first} translation for $appName
# Copyright (C) $year $author
# This file is distributed under the same license as $appName.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
msgid ""
msgstr ""${(() => strings.fold('', (prev, string) => prev + '''\n#: ${string.path}:
msgid "${string.msgid}"
msgstr "${_getTranslation(currentTranslations, string, language)}"\n'''))()}
''');
    });
  });
  print('.po files successfully updated!');
}

String _getTranslation(
    Map<String, Map<String, List<Translation>>> currentTranslations,
    Translation string,
    String language) {
  var translation = '';
  if (currentTranslations[string.path] != null &&
      (currentTranslations[string.path][language]?.isNotEmpty ?? false)) {
    var translations = currentTranslations[string.path][language]
        .where((translation) => translation.msgid == string.msgid);
    if (translations.length == 1) translation = translations.single.msgstr;
  }
  return translation;
}
