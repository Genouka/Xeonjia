import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/ui/screens/rules/rules_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/util/local_data_controller.dart';

const List<Locale> enabledLocales = [
  Locale('de'),
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hu'),
  Locale('it'),
  Locale('ru'),
  Locale('vi'),
];
final List<Locale> supportedLocales = [
  ...enabledLocales,
  const Locale('id'),
  const Locale('uk'),
  const Locale('zh'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var androidInfo =
      Platform.isAndroid ? await DeviceInfoPlugin().androidInfo : null;
  await loadStoredData().then((_) {
    Platform.isAndroid && androidInfo.version.sdkInt < 19
        ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: [SystemUiOverlay.bottom])
        : SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    if (Platform.isAndroid && androidInfo.version.sdkInt < 23) {
      settings.soundEffects = false;
      settings.backgroundMusic = false;
      settings.audioSupported = false;
      saveSettings();
    }
  });
  updateGameTheme();
  return runApp(Xeonjia());
}

class Xeonjia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return I18n(
      initialLocale: settings.locale,
      child: MaterialApp(
        title: 'Xeonjia',
        theme: appTheme,
        home: settings.firstRun ? RulesPage(HomePage()) : HomePage(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
