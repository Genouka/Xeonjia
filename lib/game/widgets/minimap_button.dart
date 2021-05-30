import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Button used to enable/disable the mini-map view
class MiniMapButton extends StatelessWidget {
  final bool miniMapIsActive;
  MiniMapButton({@required this.miniMapIsActive});

  @override
  Widget build(BuildContext context) {
    return game.map.disableMiniMap
        ? Container()
        : Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => game.messageManager.active ? null : game.miniMap(),
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
                    color: Colors.grey[800].withOpacity(0.7),
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
