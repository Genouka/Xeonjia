import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/ui/screens/rules/rules_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/util/local_data_controller.dart';

const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('es'),
  Locale('it'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadStoredData().then((_) {
    SystemChrome.setEnabledSystemUIOverlays([]);
  });
  return runApp(Xeonjia());
}

class Xeonjia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return I18n(
      initialLocale: settings.locale,
      child: MaterialApp(
        title: 'Xeonjia',
        theme: lightTheme,
        home: settings.firstRun ? RulesPage(HomePage()) : HomePage(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
      ),
    );
  }
}
