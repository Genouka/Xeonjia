import 'dart:math';
import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';

// Screen dimension
Size screenSize;

// Set screenDimensions, componentSize and defaultDistancePerFrame
void setScreenDimension(BuildContext context) {
  var _size = MediaQuery.of(context).size;
  var _padding = MediaQuery.of(context).padding;

  // 80 is life points bar plus weapon bar (40 + 40)
  screenSize =
      Size(_size.width, _size.height - _padding.bottom - _padding.top - 80);

  if (componentSize == null) {
    var rawComponentSize = max(screenSize.width, screenSize.height) / 18;
    componentSize = rawComponentSize - rawComponentSize % 4;
    defaultDistancePerFrame = componentSize / 4;
  }
}
