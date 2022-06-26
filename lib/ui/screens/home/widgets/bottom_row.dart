import 'package:flutter/material.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/info/info_page.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/util/i18n.dart';

class BottomRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: <Widget>[
          _button(context, Icons.info_outline, 'Info'.i18n, InfoPage.new),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: 2,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          _button(context, Icons.settings, 'Settings'.i18n, SettingsPage.new),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, IconData icon, String tooltip,
      Widget Function() page) {
    return IconButton(
      icon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 28),
      tooltip: tooltip,
      onPressed: () {
        Navigator.push(context, FadeRoute(page()));
      },
    );
  }
}
