import 'dart:math';

import 'package:flutter/material.dart';

/// Top left container
class InfoBox extends StatelessWidget {
  const InfoBox({
    required this.child,
    required this.onTap,
    this.radius = 30,
    this.opacity = 0.7,
    this.below = false,
    this.bottom = false,
    this.center = false,
    this.right = false,
  });
  final VoidCallback? onTap;
  final Widget child;
  final double radius;
  final double opacity;
  final bool below;
  final bool bottom;
  final bool center;
  final bool right;

  @override
  Widget build(BuildContext context) {
    double width = min(MediaQuery.of(context).size.width / 2.2, 320);
    return Positioned(
      top: bottom ? null : (below ? 46 : 6),
      left: center
          ? MediaQuery.of(context).size.width / 2 - (width / 2)
          : (right ? MediaQuery.of(context).size.width - width - 6 : 6),
      bottom: bottom ? (below ? 46 : 6) : null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          width: width,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withAlpha((255.0 * 0.7).round()),
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          child: Center(
            child: DefaultTextHeightBehavior(
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
