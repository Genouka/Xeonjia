import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/ui/screens/welcome/welcome_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var androidInfo =
      Platform.isAndroid ? await DeviceInfoPlugin().androidInfo : null;
  await loadStoredData();
  Platform.isAndroid && androidInfo!.version.sdkInt < 19
      ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom])
      : SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  if (Platform.isAndroid && androidInfo!.version.sdkInt < 23) {
    settings.soundEffects = false;
    settings.backgroundMusic = false;
    settings.audioSupported = false;
    saveSettings();
  }
  updateGameTheme();
  await Localization.loadTranslations();
  await Flame.images.loadAllImages();
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
        home: settings.firstRun ? WelcomePage(HomePage()) : HomePage(),
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
