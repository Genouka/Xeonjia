import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: const Text('SETTINGS'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            tooltip: 'Restore',
            onPressed: () {
              _restoreSettingsDialog();
            },
          ),
        ],
      ),
      body: OptionList());

  // Dialog used to restore default settings
  Future _restoreSettingsDialog() => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Restore default settings?'),
          content: const Text(
              'Are you sure you want to delete your settings and restore default ones?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Yes'),
              onPressed: () {
                SystemChrome.setEnabledSystemUIOverlays([]);
                settings = Settings({'firstRun': false});
                saveSettings();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  // Returns a tile widget for options that use drop down button
  Widget dropDownTile(String element, String title, String subtitle, int value,
          List<int> list,
          {Map<int, String> mapText}) =>
      ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: DropdownButton<int>(
          value: value,
          onChanged: (int newValue) {
            updateVariables(element, newValue);
            setState(() {
              saveSettings();
            });
          },
          items: list
              .map<DropdownMenuItem<int>>(
                (int value) => DropdownMenuItem<int>(
                  value: value,
                  child:
                      Text(mapText != null ? mapText[value] : value.toString()),
                ),
              )
              .toList(),
        ),
      );

  void refresh() {
    setState(() {});
  }
}
