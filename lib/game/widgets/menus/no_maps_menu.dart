import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// Menu displayed if there are no more maps to play
class NoMapsMenu extends StatelessWidget {
  const NoMapsMenu(this.gameRef, this.previousMapId);
  final XeonjiaGame gameRef;
  final String previousMapId;

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
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Text(
                'Unfortunately, the next part of the story is not yet available :(\nHopefully it will be available soon.\n\nIn the meantime you can support the development of Xeonjia by donating or by giving feedback.'
                    .i18n,
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
              Container(height: 35),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse('https://deepdaikon.xyz/donate'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'Donate'.i18n,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchUrl(
                          Uri.parse(
                              'https://gitlab.com/DeepDaikon/Xeonjia/issues'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'Report a bug or ask something'.i18n,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse(Uri.encodeFull('mailto:deepdaikon'
                          '@'
                          'tuta.io?subject=Xeonjia Game'));
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      'Send email'.i18n,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      mainCharacter.visitedRooms.add(previousMapId);
                      gameRef.overlays.remove('noMapsMenu');
                      gameRef.overlays.add('dialogBox');
                      gameRef.overlays.add('loading');
                      gameRef.start();
                    },
                    child: Text(
                      'Go back'.i18n,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to menu'.i18n,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
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
