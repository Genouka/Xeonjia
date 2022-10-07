import 'package:flutter/material.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  primaryColor: const Color(0xFF416AA3),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF416AA3),
    titleTextStyle:
        TextStyle(letterSpacing: 6, fontSize: 22, fontWeight: FontWeight.w600),
  ),
);

late ThemeData gameTheme;
void updateGameTheme() => gameTheme = ThemeData(
      fontFamily: settings.font,
      textTheme: TextTheme(
        headline2: TextStyle(
          color: Colors.white,
          fontSize: settings.smallerFont ? 40 : 64,
          letterSpacing: 1.4,
        ),
        headline3: TextStyle(
          color: Colors.white,
          fontSize: settings.smallerFont ? 40 : 64,
        ),
        headline6: TextStyle(
          color: Colors.white,
          fontSize: settings.smallerFont ? 36 : 48,
          letterSpacing: 1.2,
        ),
        subtitle1: TextStyle(
          color: Colors.white,
          fontSize: settings.smallerFont ? 32 : 40,
          letterSpacing: 1.4,
        ),
        subtitle2: TextStyle(
          color: Colors.white,
          fontSize: settings.smallerFont ? 32 : 40,
        ),
        bodyText1: TextStyle(
          color: Colors.white,
          fontSize: settings.smallerFont ? 24 : 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        bodyText2: TextStyle(
          fontSize: settings.smallerFont ? 24 : 32,
          color: Colors.white,
        ),
        button: TextStyle(
          fontSize: settings.smallerFont ? 16 : 24,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
