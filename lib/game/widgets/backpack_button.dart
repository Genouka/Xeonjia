import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';

// Button used to open the backpack
class BackpackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return game.map.disableMiniMap
        ? Container()
        : Positioned(
            top: 6,
            right: 56,
            child: InkWell(
              onTap: () => game.messageManager.active ||
                      game.hasAction ||
                      !game.playerOne.isStationary
                  ? null
                  : game.backpack(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.grey[800].withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                child: const Icon(Icons.backpack_rounded, color: Colors.white),
              ),
            ),
          );
  }
}
