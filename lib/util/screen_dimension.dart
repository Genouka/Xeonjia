import 'package:flutter/material.dart';

import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Screen dimension
Size screenSize;
Size physicalScreenSize;
double devicePixelRatio;

// Update screen size related variables:
// screenSize, physicalScreenSize, devicePixelRatio, componentSize, defaultSpeed
void setScreenDimension(BuildContext context) {
  var _size = MediaQuery.of(context).size;
  var _padding = MediaQuery.of(context).padding;
  devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

  screenSize = Size(_size.width, _size.height - _padding.bottom - _padding.top);
  physicalScreenSize = Size(screenSize.width * devicePixelRatio,
      screenSize.height * devicePixelRatio);

  componentSize = physicalScreenSize.longestSide / 16 / devicePixelRatio;
  characterOffset = -(componentSize / 8).gridAligned;
  defaultSpeed = 9 * componentSize;
}
