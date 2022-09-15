import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/ui/screens/home/widgets/bottom_row.dart';
import 'package:xeonjia/ui/screens/home/widgets/rain_particle_behaviour.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      body: InkWell(
        onTap: () => Navigator.push(
            context, FadeRoute(GamePage(MatchConfig(GameMode.story)))),
        child: DecoratedBox(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF438EBA), Color(0xFFA6B5C1)],
          )),
          child: AnimatedBackground(
            behaviour: RainParticleBehaviour(
              ParticleOptions(
                image: Image(
                    image: Image.asset('assets/graphics/icon_white.png').image),
                particleCount:
                    (MediaQuery.of(context).size.longestSide / 6).round(),
                spawnMinSpeed: 60,
                spawnMaxSpeed: 80,
              ),
            ),
            vsync: this,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: <Widget>[
                          Text(
                            'XEONJiA',
                            maxLines: 1,
                            style: TextStyle(
                              letterSpacing: min(
                                  24,
                                  (MediaQuery.of(context).size.width - 20) /
                                      24),
                              fontSize: min(160,
                                  (MediaQuery.of(context).size.width - 20) / 4),
                              fontFamily: 'dd5x7',
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color = Colors.black38,
                            ),
                          ),
                          Text(
                            'XEONJiA',
                            maxLines: 1,
                            style: TextStyle(
                              letterSpacing: min(
                                  24,
                                  (MediaQuery.of(context).size.width - 20) /
                                      24),
                              color: Colors.white,
                              fontSize: min(160,
                                  (MediaQuery.of(context).size.width - 20) / 4),
                              fontFamily: 'dd5x7',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 60),
                        child: Text(
                          '> ' + 'Tap to play'.i18n.toUpperCase() + ' <',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: min(
                                    48,
                                    (MediaQuery.of(context).size.width - 20) /
                                        8) /
                                (settings.useSystemFont ? 1.5 : 1),
                            fontFamily: settings.useSystemFont ? null : 'dd5x7',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BottomRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
