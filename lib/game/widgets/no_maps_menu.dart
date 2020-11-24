import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
              const Text(
                'You went too far!',
                style: TextStyle(
                    color: Colors.white, fontSize: 48, letterSpacing: 1.4),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Unfortunately, the next part of the story is not yet available :(\n'
                'Hopefully it will be available soon.\n\n'
                'In the meantime you can support the development of Xeonjia by donating or by giving feedback.',
                style: TextStyle(color: Colors.white, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              Container(height: 35),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    child: const Text(
                      'Donate',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      launch('https://deepdaikon.xyz/donate');
                    },
                  ),
                  FlatButton(
                    child: const Text(
                      'Report a bug or ask something',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      launch('https://gitlab.com/DeepDaikon/Xeonjia/issues');
                    },
                  ),
                  FlatButton(
                    child: const Text(
                      'Send email',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    onPressed: () async {
                      final url = Uri.encodeFull('mailto:deepdaikon'
                          '@'
                          'tuta.io?subject=Xeonjia Game');
                      if (await canLaunch(url)) await launch(url);
                    },
                  ),
                  FlatButton(
                    child: const Text(
                      'Go back',
                      style: TextStyle(color: Colors.white, fontSize: 32),
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
