import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Button used to call Milla
class LeafButton extends StatelessWidget {
  LeafButton(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  Widget build(BuildContext context) {
    return (gameRef.currentEventLog['milla-leaf'] ?? false)
        ? Positioned(
            top: 6,
            right: gameRef.map.disableMiniMap ? 50 : 94,
            child: InkWell(
              onTap: gameRef.millaLeaf,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                child:
                    const Icon(Icons.energy_savings_leaf, color: Colors.white),
              ),
            ),
          )
        : Container();
  }
}
