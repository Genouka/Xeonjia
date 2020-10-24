import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/util/local_data_controller.dart';

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.lightBlue[500],
        systemNavigationBarIconBrightness: Brightness.light));

    return MaterialApp(
      title: 'Xeonjia',
      theme: lightTheme,
      home: HomePage(),
    );
  }
}
