import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Menu displayed at the end of the game
class TheEndMenu extends StatelessWidget {
  const TheEndMenu(this.gameRef);
  final XeonjiaGame gameRef;

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
                'The end'.i18n,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 96),
                textAlign: TextAlign.center,
              ),
              Text(
                'Thank you.'.i18n,
                style: Theme.of(context).textTheme.bodyMedium,
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
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchUrl(
                          Uri.parse(Uri.encodeFull('mailto:deepdaikon'
                              '@'
                              'tuta.io?subject=Xeonjia Game')),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'Send email'.i18n,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to menu'.i18n,
                      style: Theme.of(context).textTheme.bodyMedium,
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
