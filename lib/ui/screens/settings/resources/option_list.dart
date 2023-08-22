import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/settings/settings_page.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// List of available options displayed in settings page
class OptionList extends StatefulWidget {
  @override
  State<OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<OptionList> {
  final _formKey = GlobalKey<FormState>();

  final _textFieldController = TextEditingController(text: mainCharacter.name);

  final Map<double, String> dPadSizes = {
    0.8: 'Smallest'.i18n,
    0.9: 'Small'.i18n,
    1: 'Default'.i18n,
    1.1: 'Large'.i18n,
    1.2: 'Largest'.i18n,
  };

  final Map<double, String> zoomOptions = {
    12: 'Zoom out'.i18n,
    9: 'Default'.i18n,
    7: 'Zoom in'.i18n,
  };

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
        behavior: NoGlow(),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(mainCharacter.name,
                          style: TextStyle(
                              fontSize: 32, fontFamily: settings.font)),
                      subtitle: Text('Click here to change your name'.i18n,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: settings.font,
                              color: Colors.grey)),
                      tileColor: Theme.of(context).primaryColor,
                      onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("What's your name?".i18n,
                                  style: TextStyle(
                                      fontSize: 32, fontFamily: settings.font),
                                  textAlign: TextAlign.center),
                              content: insertNameForm(_formKey,
                                  _textFieldController, saveName, context),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    _textFieldController.text =
                                        mainCharacter.name;
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  child: Text(
                                    'Discard'.i18n,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontFamily: settings.font),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    saveName(
                                        context, _textFieldController.text);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  child: Text(
                                    'Save'.i18n,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontFamily: settings.font),
                                  ),
                                ),
                              ],
                            );
                          }).then((_) {
                        setState(() {});
                        SystemChrome.restoreSystemUIOverlays();
                      }),
                    ),
                  ),
                  if (settings.audioSupported)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                          title: Text(
                            'Background music'.i18n,
                            style: TextStyle(
                                fontSize: 32,
                                fontFamily: settings.font,
                                color: Colors.white),
                          ),
                          activeColor: Colors.blueGrey,
                          tileColor: Theme.of(context).primaryColor,
                          subtitle: Text('Enable background music'.i18n,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: settings.font,
                                  color: Colors.grey)),
                          value: settings.backgroundMusic,
                          onChanged: (newValue) {
                            settings.backgroundMusic = newValue!;
                            (SettingsPage.of(context) as SettingsPageState)
                                .refresh();
                            saveSettings();
                          }),
                    ),
                  if (settings.audioSupported)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                          title: Text('Sound effects'.i18n,
                              style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: settings.font,
                                  color: Colors.white)),
                          activeColor: Colors.blueGrey,
                          tileColor: Theme.of(context).primaryColor,
                          subtitle: Text('Enable sound effects'.i18n,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: settings.font,
                                  color: Colors.grey)),
                          value: settings.soundEffects,
                          onChanged: (newValue) {
                            settings.soundEffects = newValue!;
                            (SettingsPage.of(context) as SettingsPageState)
                                .refresh();
                            saveSettings();
                          }),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CheckboxListTile(
                        title: Text('Show D-pad'.i18n,
                            style: TextStyle(
                                fontSize: 32,
                                fontFamily: settings.font,
                                color: Colors.white)),
                        activeColor: Colors.blueGrey,
                        tileColor: Theme.of(context).primaryColor,
                        subtitle: Text(
                            'Enable the directional pad.\nTo change its position, long-press the D-pad in the center.'
                                .i18n,
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: settings.font,
                                color: Colors.grey)),
                        value: settings.showDPad,
                        onChanged: (newValue) {
                          settings.showDPad = newValue!;
                          (SettingsPage.of(context) as SettingsPageState)
                              .refresh();
                          saveSettings();
                        }),
                  ),
                  if (settings.showDPad)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text('D-pad size'.i18n,
                            style: TextStyle(
                                fontSize: 32,
                                fontFamily: settings.font,
                                color: Colors.white)),
                        subtitle: Text('Virtual D-pad dimension'.i18n,
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: settings.font,
                                color: Colors.grey)),
                        tileColor: Theme.of(context).primaryColor,
                        trailing: DropdownButton<double>(
                          value: settings.dPadSize,
                          onChanged: (double? newValue) {
                            settings.dPadSize = newValue!;
                            saveSettings();
                            (SettingsPage.of(context) as SettingsPageState)
                                .refresh();
                          },
                          items: dPadSizes.keys
                              .toList()
                              .map<DropdownMenuItem<double>>(
                                (double value) => DropdownMenuItem<double>(
                                  value: value,
                                  child: Text(
                                    dPadSizes[value]!,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: settings.font,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Game zoom'.i18n,
                          style: TextStyle(
                              fontSize: 32,
                              fontFamily: settings.font,
                              color: Colors.white)),
                      subtitle: Text(
                          'Zoom objects in the game for a better view.'.i18n,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: settings.font,
                              color: Colors.grey)),
                      tileColor: Theme.of(context).primaryColor,
                      trailing: DropdownButton<double>(
                        value: settings.zoomIn,
                        onChanged: (double? newValue) {
                          settings.zoomIn = newValue!;
                          saveSettings();
                          (SettingsPage.of(context) as SettingsPageState)
                              .refresh();
                        },
                        items: zoomOptions.keys
                            .toList()
                            .map<DropdownMenuItem<double>>(
                              (double value) => DropdownMenuItem<double>(
                                value: value,
                                child: Text(
                                  zoomOptions[value]!,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: settings.font,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Language'.i18n,
                          style: TextStyle(
                              fontSize: 32,
                              fontFamily: settings.font,
                              color: Colors.white)),
                      subtitle: Text('App language'.i18n,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: settings.font,
                              color: Colors.grey)),
                      tileColor: Theme.of(context).primaryColor,
                      trailing: DropdownButton<Locale>(
                        value: settings.useSystemLanguage
                            ? const Locale.fromSubtags()
                            : settings.locale,
                        onChanged: (Locale? newValue) {
                          settings.locale = newValue;
                          I18n.of(context).locale = settings.locale;
                          updateGameTheme();
                          saveSettings();
                          (SettingsPage.of(context) as SettingsPageState)
                              .refresh();
                        },
                        items: <DropdownMenuItem<Locale>>[
                          DropdownMenuItem<Locale>(
                            value: const Locale.fromSubtags(),
                            child: Text(
                              'System default'.i18n,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: settings.font,
                              ),
                            ),
                          ),
                          ...supportedLocales
                              .map<DropdownMenuItem<Locale>>(
                                (value) => DropdownMenuItem<Locale>(
                                  value: value,
                                  child: Text(languageNames
                                          .containsKey(value.languageCode)
                                      ? languageNames[value.languageCode]![1]
                                      : 'missing name'),
                                ),
                              )
                              .toList()
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      );

  void saveName(BuildContext context, String text) {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
    }
  }
}
