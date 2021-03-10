import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/models/settings.dart';
import 'package:xeonjia/ui/screens/settings/resources/option_list.dart';
import 'package:xeonjia/util/local_data_controller.dart';

class SettingsPage extends StatefulWidget {
  static _SettingsPageState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Settings'.i18n.toUpperCase()),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            tooltip: 'Restore'.i18n,
            onPressed: _restoreSettingsDialog,
          ),
        ],
      ),
      body: OptionList());

  // Dialog used to restore default settings
  Future _restoreSettingsDialog() => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Restore default settings?'.i18n),
          content: Text(
              'Are you sure you want to delete your settings and restore default ones?'
                  .i18n),
          actions: <Widget>[
            TextButton(
              child: Text('Restore'.i18n),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                SystemChrome.setEnabledSystemUIOverlays([]);
                settings = Settings({'firstRun': false});
                I18n.of(context).locale = settings.locale;
                saveSettings();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'.i18n),
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        ),
      );

  void refresh() {
    setState(() {});
  }
}
