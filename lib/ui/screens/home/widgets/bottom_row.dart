import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/info/info_page.dart';
import 'package:xeonjia/ui/screens/rules/rules_page.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/ui/screens/stats/stats_page.dart';
import 'package:xeonjia/ui/basic.dart';

class bottomRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _button(context, Icons.info_outline, 'Info', InfoPage()),
        _button(context, Icons.school, 'Rules', RulesPage()),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 2,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        _button(context, Icons.equalizer, 'Ranking', StatsPage()),
        _button(context, Icons.settings, 'Settings', SettingsPage()),
      ],
    );
  }

  Widget _button(
      BuildContext context, IconData icon, String tooltip, Widget page) {
    return IconButton(
      icon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 28),
      tooltip: tooltip,
      onPressed: () {
        Navigator.push(context, FadeRoute(page));
      },
    );
  }
}
