import 'package:flutter/material.dart';

// Top left container
class InfoBox extends StatelessWidget {
  const InfoBox({
    required this.child,
    required this.onTap,
    this.radius = 30,
    this.opacity = 0.7,
    this.below = false,
  });
  final VoidCallback? onTap;
  final Widget child;
  final double radius;
  final double opacity;
  final bool below;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: below ? 46 : 6,
      left: 6,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          width: MediaQuery.of(context).size.width / 2.2,
          height: 36,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(opacity),
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          child: child,
        ),
      ),
    );
  }
}
