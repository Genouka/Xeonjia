import 'dart:ui';

import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_importer/i18n_extension_importer.dart';

const List<Locale> enabledLocales = [
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hu'),
  Locale('it'),
  Locale('ja'),
  Locale('pt'),
  Locale('ru'),
  Locale('tr'),
  Locale('vi'),
  Locale('zh', 'cn'),
  Locale('zh', 'tw'),
];
final List<Locale> supportedLocales = [
  ...enabledLocales,
  const Locale('be'),
  const Locale('bn'),
  const Locale('id'),
  const Locale('kk'),
  const Locale('nn'),
  const Locale('pl'),
  const Locale('uk'),
];
const languagesWithSpecialCharacters = ['ja', 'ru', 'uk', 'zh_cn', 'zh_tw'];
const languagesWithNonSupportedCharacters = ['be', 'bn', 'kk', 'vi'];

const Map<String, List<String>> languageNames = {
  'zh_cn': ['Chinese Simplified', '中文简体'],
  'zh_tw': ['Chinese Traditional', '中文正體'],
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
  'nn': ['Norwegian Nynorsk', 'Nynorsk'],
  'ja': ['Japanese', '日本語'],
  'kk': ['Kazakh', 'Қазақша'],
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
  static Translations _translations = Translations.byLocale('en');
  static Future<void> loadTranslations() async {
    for (final locale in supportedLocales) {
      var language =
          locale.languageCode +
          (locale.countryCode != null ? '_${locale.countryCode}' : '');
      var languagePath = language;
      if (language == 'en') continue;
      if (language == 'zh_tw') languagePath = 'zh-Hant';
      if (language == 'zh_cn') languagePath = 'zh-Hans';
      if (language == 'pt') languagePath += '-BR';
      for (final fileName in ['story', 'ui']) {
        _translations += await GettextImporter().fromAssetFile(
          language,
          'locale/$languagePath/LC_MESSAGES/$fileName.po',
        );
      }
    }
  }

  String get i18n => localize(this, _translations);
  String fill(List<Object> params) => localizeFill(this, params);
}
