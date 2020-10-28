import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/settings/resources/option_values.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/util/insert_name_form.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// List of available options displayed in settings page
class OptionList extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => ListView(children: <Widget>[
        SettingsPage.of(context).dropDownTile(
          'inputMethod',
          'Input method',
          'Method used to move',
          settings.inputMethod,
          <int>[0, 1, 2],
          mapText: inputMethods,
        ),
        if (settings.inputMethod != 0)
          SettingsPage.of(context).dropDownTile(
            'gamepadSize',
            'Gamepad size',
            'Virtual gamepad dimension',
            settings.gamepadSize.toInt(),
            gamepadSizes.keys.toList(),
            mapText: gamepadSizes,
          ),
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
            title: const Text(
              'Sound effects',
              style: TextStyle(fontSize: 20),
            ),
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
                var _textFieldController =
                    TextEditingController(text: '${mainCharacter.name}');
                return AlertDialog(
                  title: const Text('Your name', textAlign: TextAlign.center),
                  content: insertNameForm(_formKey, _textFieldController),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: Navigator.of(context).pop,
                      textColor: Theme.of(context).primaryColor,
                      child: const Text('Discard'),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          mainCharacter.name = _textFieldController.text.trim();
                          saveUserData();
                          Navigator.of(context).pop();
                        }
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: const Text('Save'),
                    ),
                  ],
                );
              }),
        ),
      ]);
}

// Update value of the chosen option
void updateVariables(String element, int newValue) {
  switch (element) {
    case 'inputMethod':
      settings.inputMethod = newValue;
      break;
    case 'gamepadSize':
      settings.gamepadSize = newValue.toDouble();
      gamepadOffset = Offset.zero;
      break;
    default:
      break;
  }
}
