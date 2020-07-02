import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blue[700],
  appBarTheme: const AppBarTheme(
    textTheme: TextTheme(
      headline6: TextStyle(
          letterSpacing: 6, fontSize: 22, fontWeight: FontWeight.w600),
    ),
  ),
);
