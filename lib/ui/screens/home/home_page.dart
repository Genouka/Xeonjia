import 'package:flutter/material.dart';

import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/ui/screens/arena/arena_page.dart';
import 'package:xeonjia/ui/screens/home/widgets/bottom_row.dart';
import 'package:xeonjia/ui/screens/home/widgets/page_button.dart';
import 'package:xeonjia/ui/screens/rules/rules_page.dart';
import 'package:xeonjia/util/screen_dimension.dart';

class HomePage extends StatelessWidget {
  final pageList = <Map<String, dynamic>>[
    {
      'title': 'Story mode',
      'goto': () => GamePage(MatchConfig(GameMode.story)),
    },
    {'title': 'Arena', 'goto': () => ArenaPage()},
    {'title': 'How to play', 'goto': () => RulesPage()},
  ];

  @override
  Widget build(BuildContext context) {
    setScreenDimension(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: appGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Expanded(
              child: Center(
                child: Text(
                  'XEONJiA',
                  style: TextStyle(
                    letterSpacing: 14,
                    color: Colors.white,
                    fontSize: 80,
                    fontFamily: 'm5x7',
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var page in pageList)
                  PageButton(
                    title: page['title'],
                    onPressed: () {
                      Navigator.push(context, FadeRoute(page['goto']()));
                    },
                  ),
              ],
            ),
            bottomRow(),
          ],
        ),
      ),
    );
  }
}
