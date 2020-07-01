import 'package:flutter/material.dart';

import 'package:xeonjia/resources/global_variables.dart';
import 'package:xeonjia/ui/screens/settings/resources/option_values.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// List of available options displayed in settings page
class OptionList extends StatelessWidget {
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
      ]);
}

// Update value of the chosen option
updateVariables(String element, int newValue) {
  switch (element) {
    case 'inputMethod':
      settings.inputMethod = newValue;
      break;
    case 'gamepadSize':
      settings.gamepadSize = newValue.toDouble();
      kGamepadOffset = Offset.zero;
      break;
    default:
      break;
  }
}
