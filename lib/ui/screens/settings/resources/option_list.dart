import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/settings/resources/option_values.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// List of available options displayed in settings page
class OptionList extends StatelessWidget {
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
        SettingsPage.of(context).checkBoxTile(
          'Fullscreen mode',
          'Enable fullscreen',
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
