// ignore_for_file: avoid_print
import 'dart:io';

import 'util/get_i18n_files.dart';

// Read each .po file inside locale and re-generate dart files inside lib/i18n
// Use this command to run the script: flutter pub run bin/update_translations
void main() {
  var translations = getCurrentTranslations(usePoFilename: true);
  Directory('lib/i18n').listSync().forEach((f) {
    f.deleteSync(recursive: true);
  });
  translations.forEach((fileName, languageTranslationsMap) {
    var newI18nFile = File('lib/i18n/$fileName.i18n.dart')..createSync();
    newI18nFile.writeAsStringSync("""
// This is a generated file; do not edit
// ignore_for_file: unnecessary_string_escapes
import 'package:i18n_extension/i18n_extension.dart';
extension Localization on String {
  static final _t = Translations.byLocale('en') + {
    ${() {
      var languagesAndTranslations = '';
      languageTranslationsMap.forEach((language, translations) {
        languagesAndTranslations += """
          '$language': {
            ${translations.fold('', (previousValue, element) {
          return previousValue +
              """'''${element.msgid.replaceAll("'", r"\'")}''':'''${element.msgstr.replaceAll("'", r"\'")}''',""";
        })}
        },""";
      });
      return languagesAndTranslations;
    }()}
};String get i18n => localize(this, _t);
String fill(List<Object> params) => localizeFill(this, params);}""");
  });
  print('Translations successfully updated!');
  print('Formatting code...');
  try {
    Process.runSync('flutter', ['format', 'lib/i18n']);
    print('Code successfully formatted');
  } catch (_) {
    print("Unable to run 'flutter format lib'");
  }
}
