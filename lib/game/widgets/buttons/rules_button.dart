import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

/// Button used to explain battles
class RulesButton extends StatelessWidget {
  RulesButton(this.game);
  final XeonjiaGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: game.map.disableMiniMap ? 50 : 94,
      child: InkWell(
        onTap: () =>
            game.messageManager.isActive ||
                game.hasAction ||
                !game.playerOne!.isStationary ||
                !game.user!.isMyTurn
            ? null
            : game.battleRules(askForConfirmation: true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          height: 34,
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withAlpha((255.0 * 0.7).round()),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          child: const Icon(Icons.menu_book, color: Colors.white),
        ),
      ),
    );
  }
}
