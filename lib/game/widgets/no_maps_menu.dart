import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Menu displayed if there are no more maps to play
class NoMapsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You went too far!'.i18n,
                style: const TextStyle(
                    color: Colors.white, fontSize: 48, letterSpacing: 1.4),
                textAlign: TextAlign.center,
              ),
              Text(
                'Unfortunately, the next part of the story is not yet available :(\nHopefully it will be available soon.\n\nIn the meantime you can support the development of Xeonjia by donating or by giving feedback.'
                    .i18n,
                style: const TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              Container(height: 35),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    child: Text(
                      'Donate'.i18n,
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      launch('https://deepdaikon.xyz/donate');
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Report a bug or ask something'.i18n,
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      launch('https://gitlab.com/DeepDaikon/Xeonjia/issues');
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Send email'.i18n,
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    onPressed: () async {
                      final url = Uri.encodeFull('mailto:deepdaikon'
                          '@'
                          'tuta.io?subject=Xeonjia Game');
                      if (await canLaunch(url)) await launch(url);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Go back'.i18n,
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      game.dispose();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
