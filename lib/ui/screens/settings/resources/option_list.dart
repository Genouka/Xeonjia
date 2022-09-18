import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// List of available options displayed in settings page
class OptionList extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _textFieldController = TextEditingController(text: mainCharacter.name);

  final Map<double, String> dPadSizes = {
    0.8: 'Smallest'.i18n,
    0.9: 'Small'.i18n,
    1: 'Default'.i18n,
    1.1: 'Large'.i18n,
    1.2: 'Largest'.i18n,
  };

  @override
  Widget build(BuildContext context) => ListView(children: <Widget>[
        ListTile(
          title: Text('Your name'.i18n, style: const TextStyle(fontSize: 20)),
          subtitle: Text('Click here to change your name'.i18n),
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Your name'.i18n, textAlign: TextAlign.center),
                  content: insertNameForm(_formKey, _textFieldController,
                      (String text) => saveName(context, text)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        _textFieldController.text = mainCharacter.name;
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text('Discard'.i18n),
                    ),
                    TextButton(
                      onPressed: () {
                        saveName(context, _textFieldController.text);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text('Save'.i18n),
                    ),
                  ],
                );
              }).then((_) => SystemChrome.restoreSystemUIOverlays()),
        ),
        if (settings.audioSupported)
          CheckboxListTile(
              title: Text(
                'Background music'.i18n,
                style: const TextStyle(fontSize: 20),
              ),
              activeColor: Colors.blueGrey,
              subtitle: Text('Enable background music'.i18n),
              value: settings.backgroundMusic,
              onChanged: (newValue) {
                settings.backgroundMusic = newValue!;
                (SettingsPage.of(context) as SettingsPageState).refresh();
                saveSettings();
              }),
        if (settings.audioSupported)
          CheckboxListTile(
              title: Text('Sound effects'.i18n,
                  style: const TextStyle(fontSize: 20)),
              activeColor: Colors.blueGrey,
              subtitle: Text('Enable sound effects'.i18n),
              value: settings.soundEffects,
              onChanged: (newValue) {
                settings.soundEffects = newValue!;
                (SettingsPage.of(context) as SettingsPageState).refresh();
                saveSettings();
              }),
        CheckboxListTile(
            title:
                Text('Show D-pad'.i18n, style: const TextStyle(fontSize: 20)),
            activeColor: Colors.blueGrey,
            subtitle: Text(
                'Enable the directional pad.\nTo change its position, long-press the D-pad in the center.'
                    .i18n),
            value: settings.showDPad,
            onChanged: (newValue) {
              settings.showDPad = newValue!;
              (SettingsPage.of(context) as SettingsPageState).refresh();
              saveSettings();
            }),
        ListTile(
          title: Text('D-pad size'.i18n, style: const TextStyle(fontSize: 20)),
          subtitle: Text('Virtual D-pad dimension'.i18n),
          trailing: DropdownButton<double>(
            value: settings.dPadSize,
            onChanged: (double? newValue) {
              settings.dPadSize = newValue!;
              saveSettings();
              (SettingsPage.of(context) as SettingsPageState).refresh();
            },
            items: dPadSizes.keys
                .toList()
                .map<DropdownMenuItem<double>>(
                  (double value) => DropdownMenuItem<double>(
                    value: value,
                    child: Text(dPadSizes[value]!),
                  ),
                )
                .toList(),
          ),
        ),
        ListTile(
          title: Text('Language'.i18n, style: const TextStyle(fontSize: 20)),
          subtitle: Text('App language'.i18n),
          trailing: DropdownButton<Locale>(
            value: settings.useSystemLanguage
                ? const Locale.fromSubtags()
                : settings.locale,
            onChanged: (Locale? newValue) {
              settings.locale = newValue;
              I18n.of(context).locale = settings.locale;
              updateGameTheme();
              saveSettings();
              (SettingsPage.of(context) as SettingsPageState).refresh();
            },
            items: <DropdownMenuItem<Locale>>[
              DropdownMenuItem<Locale>(
                value: const Locale.fromSubtags(),
                child: Text('System default'.i18n),
              ),
              ...supportedLocales
                  .map<DropdownMenuItem<Locale>>(
                    (value) => DropdownMenuItem<Locale>(
                      value: value,
                      child: Text(languageNames.containsKey(value.languageCode)
                          ? languageNames[value.languageCode]![1]
                          : 'missing name'),
                    ),
                  )
                  .toList()
            ],
          ),
        ),
      ]);

  void saveName(BuildContext context, String text) {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
    }
  }
}
