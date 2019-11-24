import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/game/utils/xeonjia_game.dart';

// Set screenDimensions, defaultComponentSize and defaultDistancePerFrame
void setScreenDimension(BuildContext context) {
  Size _size = MediaQuery.of(context).size;
  EdgeInsets _padding = MediaQuery.of(context).padding;

  screenDimensions = Size(
      _size.width,
      // 80 is life points bar plus weapon bar (40 + 40)
      _size.height - _padding.bottom - _padding.top - 80);

  // Screen width should contains ~10 components
  // componentSize should be divisible by 4 so that distancePerFrame is an int
  componentSize = _size.width / 10 - _size.width / 10 % 4;
  defaultDistancePerFrame = componentSize / 4;
}
