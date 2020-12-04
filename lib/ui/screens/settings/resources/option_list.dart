import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'package:xeonjia/main.dart';
import 'package:xeonjia/ui/screens/settings/resources/languages.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/util/insert_name_form.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// List of available options displayed in settings page
class OptionList extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _textFieldController =
      TextEditingController(text: '${mainCharacter.name}');

  @override
  Widget build(BuildContext context) => ListView(children: <Widget>[
        CheckboxListTile(
            title: const Text('Show D-Pad', style: TextStyle(fontSize: 20)),
            activeColor: Colors.blueGrey,
            subtitle: const Text('Enable directional pad'),
            value: settings.showDPad,
            onChanged: (newValue) {
              settings.showDPad = newValue;
              SettingsPage.of(context).refresh();
              saveSettings();
            }),
        CheckboxListTile(
            title: const Text(
              'Background music',
              style: TextStyle(fontSize: 20),
            ),
            activeColor: Colors.blueGrey,
            subtitle: const Text('Enable background music'),
            value: settings.backgroundMusic,
            onChanged: (newValue) {
              settings.backgroundMusic = newValue;
              SettingsPage.of(context).refresh();
              saveSettings();
            }),
        CheckboxListTile(
            title: const Text('Sound effects', style: TextStyle(fontSize: 20)),
            activeColor: Colors.blueGrey,
            subtitle: const Text('Enable sound effects'),
            value: settings.soundEffects,
            onChanged: (newValue) {
              settings.soundEffects = newValue;
              SettingsPage.of(context).refresh();
              saveSettings();
            }),
        ListTile(
          title: const Text('Your name', style: TextStyle(fontSize: 20)),
          subtitle:
              const Text('Click here to change the name used in story mode'),
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Your name', textAlign: TextAlign.center),
                  content: insertNameForm(_formKey, _textFieldController,
                      (String text) => saveName(context, text)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        _textFieldController.text = mainCharacter.name;
                        Navigator.of(context).pop();
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: const Text('Discard'),
                    ),
                    FlatButton(
                      onPressed: () {
                        saveName(context, _textFieldController.text);
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: const Text('Save'),
                    ),
                  ],
                );
              }).then((_) => SystemChrome.restoreSystemUIOverlays()),
        ),
        ListTile(
          title: const Text('Language', style: TextStyle(fontSize: 20)),
          subtitle: const Text('App language'),
          trailing: DropdownButton<Locale>(
            value: settings.useSystemLanguage ? null : settings.locale,
            onChanged: (Locale newValue) {
              settings.locale = newValue;
              I18n.of(context).locale = settings.locale;
              saveSettings();
              SettingsPage.of(context).refresh();
            },
            items: () {
              var items = <DropdownMenuItem<Locale>>[
                const DropdownMenuItem<Locale>(
                  value: null,
                  child: Text('System default'),
                )
              ];
              items.addAll(supportedLocales
                  .map<DropdownMenuItem<Locale>>(
                    (value) => DropdownMenuItem<Locale>(
                      value: value,
                      child: Text(languageName.containsKey(value.languageCode)
                          ? languageName[value.languageCode][1]
                          : 'missing name'),
                    ),
                  )
                  .toList());
              return items;
            }(),
          ),
        ),
      ]);

  void saveName(BuildContext context, String text) {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
    }
  }
}
