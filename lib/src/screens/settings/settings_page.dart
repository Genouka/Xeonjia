import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/src/resources/global_variables.dart';
import 'package:xeonjia/src/screens/settings/resources/option_list.dart';
import 'package:xeonjia/src/util/app_settings.dart';
import 'package:xeonjia/src/util/local_data_controller.dart';

class SettingsPage extends StatefulWidget {
  static _SettingsPageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_SettingsPageState>());

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('S E T T I N G S'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings_backup_restore),
              tooltip: 'Restore',
              onPressed: () {
                _restoreSettingsDialog();
              },
            ),
          ]),
      body: OptionList());

  // Dialog used to restore default settings
  _restoreSettingsDialog() => showDialog(
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
                  settings = AppSettings({});
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
          ));

  // Returns a tile widget for options that use drop down button
  Widget dropDownTile(String element, String title, String subtitle, int value,
          List<int> list,
          {Map<int, String> mapText}) =>
      ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: kTextFontSize,
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
                .map<DropdownMenuItem<int>>((int value) =>
                    DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                          mapText != null ? mapText[value] : value.toString()),
                    ))
                .toList(),
          ));

  // Returns a checkbox tile. Used only for fullscreen option, for now
  Widget checkBoxTile(String title, String subtitle) => CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: kTextFontSize,
        ),
      ),
      activeColor: Colors.blueGrey,
      subtitle: Text(subtitle),
      value: settings.fullScreen,
      onChanged: (_fullScreen) {
        setState(() {
          settings.fullScreen = _fullScreen;
          if (settings.fullScreen) {
            SystemChrome.setEnabledSystemUIOverlays([]);
          } else {
            SystemChrome.setEnabledSystemUIOverlays(
                [SystemUiOverlay.top, SystemUiOverlay.bottom]);
          }
        });
        saveSettings();
      });
}
