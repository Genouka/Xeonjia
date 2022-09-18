import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Button used to explain battles
class RulesButton extends StatelessWidget {
  RulesButton(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: gameRef.map.disableMiniMap ? 50 : 94,
      child: InkWell(
        onTap: () => gameRef.messageManager.isActive ||
                gameRef.hasAction ||
                !gameRef.playerOne!.isStationary ||
                !gameRef.playerOne!.isMyTurn
            ? null
            : gameRef.battleRules(askForConfirmation: true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          height: 34,
          decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.7),
              borderRadius: const BorderRadius.all(Radius.circular(30))),
          child: const Icon(Icons.menu_book, color: Colors.white),
        ),
      ),
    );
  }
}
