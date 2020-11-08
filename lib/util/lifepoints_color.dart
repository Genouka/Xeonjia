import 'package:flutter/material.dart';

Color lifePointsColor(double percentage) {
  if (percentage > 2 / 3) return Colors.green;
  return (percentage > 1 / 3) ? Colors.orange : Colors.red;
}
