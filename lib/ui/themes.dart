import 'package:flutter/material.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF111111),
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(secondary: Colors.grey),
  appBarTheme: const AppBarTheme(
    toolbarHeight: 80,
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
);

late ThemeData gameTheme;
void updateGameTheme() => gameTheme = ThemeData(
  fontFamily: settings.font,
  textTheme: TextTheme(
    displayMedium: TextStyle(
      color: Colors.white,
      fontSize: settings.smallerFont ? 40 : 64,
      letterSpacing: 1.4,
      height: 1,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontSize: settings.smallerFont ? 40 : 64,
      height: 1,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: settings.smallerFont ? 36 : 48,
      letterSpacing: 1.2,
      height: 1,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: settings.smallerFont ? 32 : 40,
      letterSpacing: 1.4,
      height: 1,
    ),
    titleSmall: TextStyle(
      color: Colors.white,
      fontSize: settings.smallerFont ? 32 : 40,
      height: 1,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: settings.smallerFont ? 24 : 32,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      height: 1,
    ),
    bodyMedium: TextStyle(
      fontSize: settings.smallerFont ? 24 : 32,
      color: Colors.white,
      height: 1,
    ),
    labelLarge: TextStyle(
      fontSize: settings.smallerFont ? 16 : 24,
      color: Colors.white,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      height: 1,
    ),
  ),
);
