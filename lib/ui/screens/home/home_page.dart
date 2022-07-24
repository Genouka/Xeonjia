import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/arena/arena_page.dart';
import 'package:xeonjia/ui/screens/game/game_page.dart';
import 'package:xeonjia/ui/screens/home/widgets/bottom_row.dart';
import 'package:xeonjia/ui/screens/home/widgets/page_button.dart';
import 'package:xeonjia/ui/screens/rules/rules_page.dart';
import 'package:xeonjia/utils/game_properties.dart';
import 'package:xeonjia/utils/i18n.dart';

class HomePage extends StatelessWidget {
  List<Map<String, dynamic>> pageList() {
    return [
      {
        'title': 'Story mode'.i18n,
        'goto': () => GamePage(MatchConfig(GameMode.story)),
      },
      {'title': 'Multiplayer'.i18n, 'goto': ArenaPage.new},
      {'title': 'How to play'.i18n, 'goto': RulesPage.new},
    ];
  }

  @override
  Widget build(BuildContext context) {
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF7BA1C1),
          image: DecorationImage(
            image: AssetImage('assets/graphics/home_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Expanded(
              child: Center(
                child: Text(
                  'XEONJiA',
                  maxLines: 1,
                  style: TextStyle(
                    letterSpacing: 14,
                    color: Colors.white,
                    fontSize: 80,
                    fontFamily: 'dd5x7',
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var page in pageList())
                  PageButton(
                    title: page['title'],
                    onPressed: () =>
                        Navigator.push(context, FadeRoute(page['goto']())),
                  ),
              ],
            ),
            BottomRow(),
          ],
        ),
      ),
    );
  }
}
