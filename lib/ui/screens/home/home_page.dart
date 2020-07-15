import 'package:flutter/material.dart';

import 'package:xeonjia/models/game_mode.dart';
import 'package:xeonjia/models/match_config.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/ui/screens/arena/arena_page.dart';
import 'package:xeonjia/ui/screens/home/widgets/bottom_row.dart';
import 'package:xeonjia/ui/screens/home/widgets/page_button.dart';
import 'package:xeonjia/ui/screens/user/user_page.dart';
import 'package:xeonjia/util/screen_dimension.dart';

class HomePage extends StatelessWidget {
  final pageList = <Map<String, dynamic>>[
    {
      'title': 'Story mode',
      'goto': () => GamePage(MatchConfig(GameMode.story))
    },
    {'title': 'Arena', 'goto': () => ArenaPage()},
    {'title': 'Character', 'goto': () => UserPage(appBarCollapsed: true)},
  ];

  @override
  Widget build(BuildContext context) {
    setScreenDimension(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.light
                ? appGradient
                : darkAppGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Expanded(
              flex: 5,
              child: Center(
                child: Text(
                  'XEONJiA',
                  style: TextStyle(
                    letterSpacing: 14,
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            for (var page in pageList)
              PageButton(
                title: page['title'],
                onPressed: () {
                  Navigator.push(context, FadeRoute(page['goto']()));
                },
              ),
            const Spacer(),
            bottomRow(),
          ],
        ),
      ),
    );
  }
}
