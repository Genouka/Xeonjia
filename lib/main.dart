import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/util/local_data_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadStoredData().then((_) {
    if (settings.fullScreen) SystemChrome.setEnabledSystemUIOverlays([]);
  });
  await Flame.images.loadAll([
    'character-1.png',
    'character-1-punch.png',
    'character-1-walk.png',
    'character-2.png',
    'character-2-punch.png',
    'character-2-walk.png',
    'character-3.png',
    'character-3-punch.png',
    'character-3-walk.png',
    'character-4.png',
    'character-4-punch.png',
    'character-4-walk.png',
  ]);
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
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.lightBlue[700],
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
            headline6: TextStyle(
                letterSpacing: 6, fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
