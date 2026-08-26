import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/ui/screens/welcome/welcome_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var androidInfo = !kIsWeb && Platform.isAndroid
      ? await DeviceInfoPlugin().androidInfo
      : null;
  await loadStoredData();
  !kIsWeb && Platform.isAndroid && androidInfo!.version.sdkInt < 19
      ? SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom],
        )
      : SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  if (!kIsWeb && Platform.isAndroid && androidInfo!.version.sdkInt < 23) {
    settings.soundEffects = false;
    settings.backgroundMusic = false;
    settings.audioSupported = false;
    saveSettings();
  } else if (!kIsWeb && Platform.isLinux) {
    await windowManager.ensureInitialized();
    settings.soundEffects = false;
    saveSettings();
    windowManager.setMinimumSize(const Size(400, 500));
    windowManager.setMaximumSize(Size.infinite);
  } else if (!kIsWeb && Platform.isWindows) {
    windowManager.setFullScreen(true);
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
        home: settings.firstRun ? WelcomePage() : HomePage(),
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
