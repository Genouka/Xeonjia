import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  primaryColor: const Color(0xFF416AA3),
  appBarTheme: const AppBarTheme(
    textTheme: TextTheme(
      headline6: TextStyle(
          letterSpacing: 6, fontSize: 22, fontWeight: FontWeight.w600),
    ),
  ),
);
