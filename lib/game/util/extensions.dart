import 'dart:ui';
import 'package:flutter/foundation.dart';

// Whether other has a nonzero area of overlap with this rectangle
// Used instead of overlaps to allow floating point precision loss in calculations
extension RectOverlap on Rect {
  bool approximateOverlaps(Rect other) {
    return ((right - other.left) <= precisionErrorTolerance ||
            (other.right - left) <= precisionErrorTolerance ||
            (bottom - other.top) <= precisionErrorTolerance ||
            (other.bottom - top) <= precisionErrorTolerance)
        ? false
        : true;
  }
}

// The number of device pixels for each logical pixel
double devicePixelRatio;

// Align to the physical pixel grid
// `this` should be a size in logical pixels to make sense
extension PixelGrid on num {
  num get gridAligned => (this * devicePixelRatio).round() / devicePixelRatio;
}

// Round up to the nearest multiple of 16
extension Round16 on double {
  double get round16 => this % 16 == 0 ? this : (floor() + 16 & ~15).toDouble();
}
