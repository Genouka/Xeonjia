import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Button used to enable/disable the mini-map view
class MiniMapButton extends StatelessWidget {
  MiniMapButton(this.game, {required this.miniMapIsActive});
  final XeonjiaGame game;
  final bool miniMapIsActive;

  @override
  Widget build(BuildContext context) {
    return game.map.disableMiniMap
        ? Container()
        : Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => game.isMiniMapButtonActive ? game.miniMap() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                height: 36,
                width: miniMapIsActive
                    ? MediaQuery.of(context).size.width / 2.2
                    : null,
                constraints: miniMapIsActive
                    ? const BoxConstraints(maxWidth: 320)
                    : null,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withAlpha((255.0 * 0.7).round()),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                ),
                child: miniMapIsActive
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Close'.i18n.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge,
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
