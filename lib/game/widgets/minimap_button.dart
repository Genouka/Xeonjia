import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

// Button used to enable/disable the mini-map view
class MiniMapButton extends StatelessWidget {
  MiniMapButton(this.gameRef, {required this.miniMapIsActive});
  final XeonjiaGame gameRef;
  final bool miniMapIsActive;

  @override
  Widget build(BuildContext context) {
    return gameRef.map.disableMiniMap
        ? Container()
        : Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => gameRef.messageManager.active ||
                      gameRef.hasAction ||
                      !gameRef.playerOne!.isStationary
                  ? null
                  : gameRef.miniMap(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                height: 34,
                width: miniMapIsActive
                    ? MediaQuery.of(context).size.width / 2.2
                    : null,
                constraints: miniMapIsActive
                    ? const BoxConstraints(maxWidth: 320)
                    : null,
                decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                child: miniMapIsActive
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Close map'.i18n.toUpperCase(),
                              style: Theme.of(context).textTheme.button,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(Icons.close, color: Colors.white),
                        ],
                      )
                    : const Icon(Icons.map, color: Colors.white),
              ),
            ),
          );
  }
}
