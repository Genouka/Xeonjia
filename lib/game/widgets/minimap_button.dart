import 'package:flutter/material.dart';

import 'package:xeonjia/i18n/story.i18n.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Button used to enable/disable the mini-map view
class MiniMapButton extends StatelessWidget {
  final bool miniMapEnabled;
  MiniMapButton({@required this.miniMapEnabled});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: InkWell(
        onTap: () => game.messageManager.active ? null : game.miniMap(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          height: 34,
          width:
              miniMapEnabled ? MediaQuery.of(context).size.width / 2.2 : null,
          constraints:
              miniMapEnabled ? const BoxConstraints(maxWidth: 320) : null,
          decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(0.7),
              borderRadius: const BorderRadius.all(Radius.circular(30))),
          child: miniMapEnabled
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    Text(
                      'Close map'.i18n.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    const Spacer(),
                    const Icon(Icons.close, color: Colors.white),
                  ],
                )
              : const Icon(Icons.map, color: Colors.white),
        ),
      ),
    );
  }
}
