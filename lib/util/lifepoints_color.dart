import 'package:flutter/material.dart';

Color lifePointsColor(double currentLifePoints) {
  if (currentLifePoints > 2 / 3) return Colors.green;
  return (currentLifePoints > 1 / 3) ? Colors.orange : Colors.red;
}
