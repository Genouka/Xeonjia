// ignore_for_file: avoid_print
import 'dart:io';

import 'util/dart2po.dart';
import 'util/get_i18n_files.dart';
import 'util/tmx2po.dart';
import 'util/translation.dart';

final languageList = ['de', 'es', 'it', 'template'];
final appName = 'Xeonjia';
final author = 'DeepDaikon';
final year = '2020';

var metadata = <String, String>{};

// Read each .dart, .tmx, .tsx file and re-generate .po files inside locale
// Use this command to run the script: flutter pub run bin/update_po_files
void main() {
  // filename : [...msgids]
  var dirStringsMap = <String, List<Translation>>{};
  dirStringsMap.addAll(dart2po());
  dirStringsMap.addAll(tmx2po());

  var currentTranslations = getCurrentTranslations();
  Directory('locale').listSync().forEach((f) => f.deleteSync(recursive: true));
  languageList.forEach((language) {
    dirStringsMap.forEach((fileName, strings) {
      var newPoFile = File('locale/$language/LC_MESSAGES/$fileName.po')
        ..createSync(recursive: true);
      newPoFile.writeAsStringSync('''
${metadata[newPoFile.path] ?? '''
# Translation for $appName
# Copyright (C) $year $author
# This file is distributed under the same license as $appName.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
msgid ""
msgstr ""
"Project-Id-Version: \\n"
"POT-Creation-Date: \\n"
"PO-Revision-Date: \\n"
"Language-Team: \\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Last-Translator: Automatically generated\\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\\n"
"Language: $language\\n"'''}${(() => strings.fold('', (prev, string) => prev + '''\n\n#: ${string.path}:
msgid "${string.msgid}"
msgstr "${_getTranslation(currentTranslations, string, language)}"'''))()}
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
