import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';

// Set screenDimensions
void setScreenDimension(BuildContext context) {
  Size _size = MediaQuery.of(context).size;
  EdgeInsets _padding = MediaQuery.of(context).padding;

  screenWidth = _size.width;
  // 80 is life points bar plus weapon bar (40 + 40)
  screenHeight = _size.height - _padding.bottom - _padding.top - 80;
}
