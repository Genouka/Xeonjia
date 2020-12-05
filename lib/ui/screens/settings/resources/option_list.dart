import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
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
            title:
                Text('Show D-Pad'.i18n, style: const TextStyle(fontSize: 20)),
            activeColor: Colors.blueGrey,
            subtitle: Text('Enable directional pad'.i18n),
            value: settings.showDPad,
            onChanged: (newValue) {
              settings.showDPad = newValue;
              SettingsPage.of(context).refresh();
              saveSettings();
            }),
        CheckboxListTile(
            title: Text(
              'Background music'.i18n,
              style: const TextStyle(fontSize: 20),
            ),
            activeColor: Colors.blueGrey,
            subtitle: Text('Enable background music'.i18n),
            value: settings.backgroundMusic,
            onChanged: (newValue) {
              settings.backgroundMusic = newValue;
              SettingsPage.of(context).refresh();
              saveSettings();
            }),
        CheckboxListTile(
            title: Text('Sound effects'.i18n,
                style: const TextStyle(fontSize: 20)),
            activeColor: Colors.blueGrey,
            subtitle: Text('Enable sound effects'.i18n),
            value: settings.soundEffects,
            onChanged: (newValue) {
              settings.soundEffects = newValue;
              SettingsPage.of(context).refresh();
              saveSettings();
            }),
        ListTile(
          title: Text('Your name'.i18n, style: const TextStyle(fontSize: 20)),
          subtitle:
              Text('Click here to change the name used in story mode'.i18n),
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Your name'.i18n, textAlign: TextAlign.center),
                  content: insertNameForm(_formKey, _textFieldController,
                      (String text) => saveName(context, text)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        _textFieldController.text = mainCharacter.name;
                        Navigator.of(context).pop();
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: Text('Discard'.i18n),
                    ),
                    FlatButton(
                      onPressed: () {
                        saveName(context, _textFieldController.text);
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: Text('Save'.i18n),
                    ),
                  ],
                );
              }).then((_) => SystemChrome.restoreSystemUIOverlays()),
        ),
        ListTile(
          title: Text('Language'.i18n, style: const TextStyle(fontSize: 20)),
          subtitle: Text('App language'.i18n),
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
                DropdownMenuItem<Locale>(
                  value: null,
                  child: Text('System default'.i18n),
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
