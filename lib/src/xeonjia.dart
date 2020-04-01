import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/src/screens/home/home_page.dart';

class Xeonjia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system overlay color
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
            title: TextStyle(
                letterSpacing: 6, fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
