import 'dart:ui';

import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';

const List<Locale> enabledLocales = [
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hu'),
  Locale('it'),
  Locale('ja'),
  Locale('ru'),
  Locale('tr'),
  Locale('vi'),
];
final List<Locale> supportedLocales = [
  ...enabledLocales,
  const Locale('be'),
  const Locale('bn'),
  const Locale('id'),
  const Locale('uk'),
  const Locale('zh'),
];
const languagesWithSpecialCharacters = [
  'be',
  'bn',
  'ja',
  'ru',
  'uk',
  'vi',
  'zh',
];

const Map<String, List<String>> languageNames = {
  'zh': ['Chinese', '汉语'],
  'es': ['Spanish', 'Español'],
  'en': ['English', 'English'],
  'be': ['Belarusian', 'беларуская мова'],
  'bn': ['Bengali', 'বাংলা'],
  'id': ['Indonesian', 'Bahasa Indonesia'],
  'uk': ['Ukrainian', 'украї́нська мо́ва'],
  'ar': ['Arabic', 'العربية'],
  'he': ['Hebrew', 'עברית'],
  'hu': ['Hungarian', 'Magyar'],
  'vi': ['Vietnamese', 'Tiếng Việt'],
  'pt': ['Portuguese', 'Português'],
  'ro': ['Romanian', 'Română'],
  'ru': ['Russian', 'Русский'],
  'ja': ['Japanese', '日本語'],
  'de': ['German', 'Deutsch'],
  'ko': ['Korean', '한국어'],
  'fr': ['French', 'Français'],
  'tr': ['Turkish', 'Türkçe'],
  'it': ['Italian', 'Italiano'],
  'pl': ['Polish', 'Polski'],
  'bg': ['Bulgarian', 'български език'],
  'nl': ['Dutch', 'Nederlands'],
  'el': ['Greek', 'Ελληνικά'],
  'no': ['Norwegian', 'Norsk'],
  'da': ['Danish', 'Dansk'],
  'fi': ['Finnish', 'Suomi'],
  'eo': ['Esperanto', 'Esperanto'],
  'ia': ['Interlingua', 'Interlingua'],
};

extension Localization on String {
  static TranslationsByLocale _translations = Translations.byLocale('en');
  static Future<void> loadTranslations() async {
    for (final locale in supportedLocales) {
      var language = locale.languageCode;
      if (language == 'en') continue;
      if (language == 'zh') language += '_Hans';
      if (language == 'pt') language += '_BR';
      for (final fileName in ['story', 'ui']) {
        _translations += await GettextImporter().fromAssetFile(
            locale.languageCode, 'locale/$language/LC_MESSAGES/$fileName.po');
      }
    }
  }

  String get i18n => localize(this, _translations);
  String fill(List<Object> params) => localizeFill(this, params);
}
