import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Set screenDimensions, componentSize and defaultDistancePerFrame
void setScreenDimension(BuildContext context) {
  Size _size = MediaQuery.of(context).size;
  EdgeInsets _padding = MediaQuery.of(context).padding;

  screenWidth = _size.width;
  // 80 is life points bar plus weapon bar (40 + 40)
  screenHeight = _size.height - _padding.bottom - _padding.top - 80;

  if (componentSize == null) {
    double rawComponentSize = max(screenWidth, screenHeight) / 15;
    componentSize = rawComponentSize - rawComponentSize % 4;
    defaultDistancePerFrame = componentSize / 4;
  }
}
