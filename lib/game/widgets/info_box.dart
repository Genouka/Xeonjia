import 'package:flutter/material.dart';
import 'package:xeonjia/game/widgets/pause_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Top left container
class InfoBox extends StatelessWidget {
  const InfoBox({this.child, this.radius = 30, this.below = false});
  final Widget child;
  final double radius;
  final bool below;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: below ? 46 : 6,
      left: 6,
      child: InkWell(
        onTap: () => game.messageManager.active
            ? null
            : game.pause(mode: PauseMode.pause),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          width: MediaQuery.of(context).size.width / 2.2,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(0.7),
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          child: child,
        ),
      ),
    );
  }
}
