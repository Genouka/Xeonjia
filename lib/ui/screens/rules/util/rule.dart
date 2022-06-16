import 'package:flutter/material.dart';

// Game rule
class Rule {
  Rule({
    required this.title,
    required this.subtitle,
    this.image,
    this.icon,
  });

  // Rule title
  final String title;

  // Rule description
  final String subtitle;

  // Rule image
  final String? image;

  // Rule icon (instead of image)
  final IconData? icon;
}
