import 'dart:io';
import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/ui/screens/home/widgets/bottom_row.dart';
import 'package:xeonjia/ui/screens/home/widgets/rain_particle_behaviour.dart';
import 'package:xeonjia/ui/screens/info/info_page.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  void startGame() => Navigator.push(context, FadeRoute(GamePage()));

  @override
  Widget build(BuildContext context) {
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    setComponentSize(MediaQuery.of(context).size);
    return Scaffold(
      body: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              startGame();
            } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
              Navigator.push(context, FadeRoute(InfoPage()));
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              Navigator.push(context, FadeRoute(SettingsPage()));
            }
          }
          return KeyEventResult.handled;
        },
        child: InkWell(
          onTap: startGame,
          overlayColor:
              MaterialStateColor.resolveWith((states) => Colors.transparent),
          child: DecoratedBox(
            decoration: gradientDecoration(withOpacity: true),
            child: AnimatedBackground(
              behaviour: RainParticleBehaviour(
                ParticleOptions(
                  image: Image(
                      image:
                          Image.asset('assets/graphics/icon_white.png').image),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
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
                                fontSize: min(
                                  MediaQuery.of(context).size.height / 1.75,
                                  min(
                                      160,
                                      (MediaQuery.of(context).size.width - 20) /
                                          4),
                                ),
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
                                fontSize: min(
                                    MediaQuery.of(context).size.height / 1.75,
                                    min(
                                        160,
                                        (MediaQuery.of(context).size.width -
                                                20) /
                                            4)),
                                fontFamily: 'dd5x7',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Ice Adventures'.i18n,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: min(
                                    MediaQuery.of(context).size.height / 6,
                                    min(
                                        72,
                                        (MediaQuery.of(context).size.width -
                                                20) /
                                            8)) /
                                (settings.smallerFont ? 1.5 : 1),
                            fontFamily: settings.font,
                          ),
                        ),
                        const Spacer(),
                        const Spacer(),
                        Text(
                          (Platform.isAndroid
                                  ? 'Tap to play'.i18n
                                  : 'Press enter'.i18n)
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: min(
                                    MediaQuery.of(context).size.height / 8,
                                    min(
                                        48,
                                        (MediaQuery.of(context).size.width -
                                                20) /
                                            10)) /
                                (settings.smallerFont ? 1.5 : 1),
                            fontFamily: settings.font,
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
      ),
    );
  }
}
