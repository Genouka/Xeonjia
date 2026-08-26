import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/utils/data_transfer.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _textFieldController = TextEditingController(text: mainCharacter.name);
  int focusItem = -1;

  Map<double, String> get dPadSizes => {
    0.8: 'Smallest'.i18n,
    0.9: 'Small'.i18n,
    1: 'Default'.i18n,
    1.1: 'Large'.i18n,
    1.2: 'Largest'.i18n,
  };

  Map<double, String> get zoomOptions => {
    12: 'Zoom out'.i18n,
    9: 'Default'.i18n,
    7: 'Zoom in'.i18n,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Settings'.i18n.toUpperCase()),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: settings.smallerFont ? 34 : 48,
        fontWeight: FontWeight.w600,
        fontFamily: settings.font,
      ),
      leading: Container(),
      actions: [
        closeButton(
          context,
          (bool focus) => setState(() => focus ? focusItem = -1 : null),
        ),
      ],
    ),
    extendBodyBehindAppBar: true,
    body: DecoratedBox(
      decoration: gradientDecoration(),
      child: ScrollConfiguration(
        behavior: NoGlow(),
        child: Container(
          color: Colors.black45,
          child: Column(
            children: [
              Container(height: 80),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          color: focusItem == 0
                              ? Colors.white24
                              : Colors.white12,
                          child: Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              onFocusChange: (bool focus) => setState(() {
                                focus ? focusItem = 0 : null;
                              }),
                              title: Text(
                                mainCharacter.name,
                                style: TextStyle(
                                  fontSize: settings.smallerFont ? 24 : 32,
                                  fontFamily: settings.font,
                                  height: 1,
                                ),
                              ),
                              subtitle: Text(
                                'Click here to change your name'.i18n,
                                style: TextStyle(
                                  fontSize: settings.smallerFont ? 18 : 24,
                                  fontFamily: settings.font,
                                  color: Colors.white70,
                                  height: 1,
                                ),
                              ),
                              onTap: () =>
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "What's your name?".i18n,
                                          style: TextStyle(
                                            fontSize: settings.smallerFont
                                                ? 24
                                                : 32,
                                            fontFamily: settings.font,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        content: insertNameForm(
                                          _formKey,
                                          _textFieldController,
                                          saveName,
                                          context,
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              _textFieldController.text =
                                                  mainCharacter.name;
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: Text(
                                              'Discard'.i18n,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: settings.smallerFont
                                                    ? 20
                                                    : 24,
                                                fontFamily: settings.font,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              saveName(
                                                context,
                                                _textFieldController.text,
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: Text(
                                              'Save'.i18n,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: settings.smallerFont
                                                    ? 20
                                                    : 24,
                                                fontFamily: settings.font,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ).then((_) {
                                    setState(() {});
                                    SystemChrome.restoreSystemUIOverlays();
                                  }),
                            ),
                          ),
                        ),
                        if (settings.audioSupported)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            color: focusItem == 1
                                ? Colors.white24
                                : Colors.white12,
                            child: Material(
                              type: MaterialType.transparency,
                              child: CheckboxListTile(
                                onFocusChange: (bool focus) => setState(() {
                                  focus ? focusItem = 1 : null;
                                }),
                                checkColor: Colors.white,
                                title: Text(
                                  'Background music'.i18n,
                                  style: TextStyle(
                                    fontSize: settings.smallerFont ? 24 : 32,
                                    fontFamily: settings.font,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                activeColor: Colors.transparent,
                                subtitle: Text(
                                  'Enable background music'.i18n,
                                  style: TextStyle(
                                    fontSize: settings.smallerFont ? 20 : 24,
                                    fontFamily: settings.font,
                                    color: Colors.white70,
                                    height: 1,
                                  ),
                                ),
                                value: settings.backgroundMusic,
                                onChanged: (newValue) {
                                  settings.backgroundMusic = newValue!;
                                  setState(() {});
                                  saveSettings();
                                },
                              ),
                            ),
                          ),
                        if (settings.audioSupported)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            color: focusItem == 2
                                ? Colors.white24
                                : Colors.white12,
                            child: Material(
                              type: MaterialType.transparency,
                              child: CheckboxListTile(
                                onFocusChange: (bool focus) => setState(() {
                                  focus ? focusItem = 2 : null;
                                }),
                                checkColor: Colors.white,
                                title: Text(
                                  'Sound effects'.i18n,
                                  style: TextStyle(
                                    fontSize: settings.smallerFont ? 24 : 32,
                                    fontFamily: settings.font,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                activeColor: Colors.transparent,
                                subtitle: Text(
                                  'Enable sound effects'.i18n,
                                  style: TextStyle(
                                    fontSize: settings.smallerFont ? 20 : 24,
                                    fontFamily: settings.font,
                                    color: Colors.white70,
                                    height: 1,
                                  ),
                                ),
                                value: settings.soundEffects,
                                onChanged: (newValue) {
                                  settings.soundEffects = newValue!;
                                  setState(() {});
                                  saveSettings();
                                },
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          color: focusItem == 3
                              ? Colors.white24
                              : Colors.white12,
                          child: Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              onFocusChange: (bool focus) => setState(() {
                                focus ? focusItem = 3 : null;
                              }),
                              title: Text(
                                'Controller'.i18n,
                                style: TextStyle(
                                  fontSize: settings.smallerFont ? 24 : 32,
                                  fontFamily: settings.font,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              subtitle: Text(
                                'Move the character with gestures or virtual D-pad'
                                        .i18n +
                                    ((!kIsWeb && Platform.isAndroid)
                                        ? ''
                                        : '.\n' +
                                              'You only need it on a touchscreen device'
                                                  .i18n),
                                style: TextStyle(
                                  fontSize: settings.smallerFont ? 20 : 24,
                                  fontFamily: settings.font,
                                  color: Colors.white70,
                                  height: 1,
                                ),
                              ),
                              trailing: DropdownButton<bool>(
                                alignment: AlignmentDirectional.centerEnd,
                                underline: const SizedBox(),
                                value: settings.showDPad,
                                onChanged: (bool? newValue) {
                                  settings.showDPad = newValue!;
                                  saveSettings();
                                  setState(() {});
                                },
                                items: [true, false]
                                    .map<DropdownMenuItem<bool>>(
                                      (bool value) => DropdownMenuItem<bool>(
                                        value: value,
                                        child: Text(
                                          value
                                              ? 'D-pad'.i18n
                                              : 'Gestures'.i18n,
                                          style: TextStyle(
                                            fontSize: settings.smallerFont
                                                ? 20
                                                : 24,
                                            fontFamily: settings.font,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        if (settings.showDPad)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            color: focusItem == 4
                                ? Colors.white24
                                : Colors.white12,
                            child: Material(
                              type: MaterialType.transparency,
                              child: ListTile(
                                onFocusChange: (bool focus) => setState(() {
                                  focus ? focusItem = 4 : null;
                                }),
                                title: Text(
                                  'D-pad size'.i18n,
                                  style: TextStyle(
                                    fontSize: settings.smallerFont ? 24 : 32,
                                    fontFamily: settings.font,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                subtitle: Text(
                                  'Virtual D-pad dimension.\nTo change its position, long-press the D-pad in the center.'
                                      .i18n,
                                  style: TextStyle(
                                    fontSize: settings.smallerFont ? 20 : 24,
                                    fontFamily: settings.font,
                                    color: Colors.white70,
                                    height: 1,
                                  ),
                                ),
                                trailing: DropdownButton<double>(
                                  alignment: AlignmentDirectional.centerEnd,
                                  underline: const SizedBox(),
                                  value: settings.dPadSize,
                                  onChanged: (double? newValue) {
                                    settings.dPadSize = newValue!;
                                    saveSettings();
                                    setState(() {});
                                  },
                                  items: dPadSizes.keys
                                      .toList()
                                      .map<DropdownMenuItem<double>>(
                                        (double value) =>
                                            DropdownMenuItem<double>(
                                              value: value,
                                              child: Text(
                                                dPadSizes[value]!,
                                                style: TextStyle(
                                                  fontSize: settings.smallerFont
                                                      ? 20
                                                      : 24,
                                                  fontFamily: settings.font,
                                                ),
                                              ),
                                            ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        /*
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              color: focusItem == 5
                                  ? Colors.white24
                                  : Colors.white12,
                              child: ListTile(
                                onFocusChange: (bool focus) => setState(() {
                                  focus ? focusItem = 5 : null;
                                }),
                                title: Text('Game zoom'.i18n,
                                    style: TextStyle(
                                        fontSize:
                                            settings.smallerFont ? 24 : 32,
                                        fontFamily: settings.font,
                                        color: Colors.white)),
                                subtitle: Text(
                                    'Zoom objects in the game for a better view'
                                        .i18n,
                                    style: TextStyle(
                                        fontSize:
                                            settings.smallerFont ? 20 : 24,
                                        fontFamily: settings.font,
                                        color: Colors.white70)),
                                trailing: DropdownButton<double>(
                                  alignment: AlignmentDirectional.centerEnd,
                                  underline: const SizedBox(),
                                  value: settings.zoomIn,
                                  onChanged: (double? newValue) {
                                    settings.zoomIn = newValue!;
                                    saveSettings();
                                    setState(() {});
                                  },
                                  items: zoomOptions.keys
                                      .toList()
                                      .map<DropdownMenuItem<double>>(
                                        (double value) =>
                                            DropdownMenuItem<double>(
                                          value: value,
                                          child: Text(
                                            zoomOptions[value]!,
                                            style: TextStyle(
                                              fontSize: settings.smallerFont
                                                  ? 20
                                                  : 24,
                                              fontFamily: settings.font,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),*/
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          color: focusItem == 6
                              ? Colors.white24
                              : Colors.white12,
                          child: Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              onFocusChange: (bool focus) => setState(() {
                                focus ? focusItem = 6 : null;
                              }),
                              title: Text(
                                'Language'.i18n,
                                style: TextStyle(
                                  fontSize: settings.smallerFont ? 24 : 32,
                                  fontFamily: settings.font,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              subtitle: Text(
                                'App language'.i18n,
                                style: TextStyle(
                                  fontSize: settings.smallerFont ? 20 : 24,
                                  fontFamily: settings.font,
                                  color: Colors.white70,
                                  height: 1,
                                ),
                              ),
                              trailing: DropdownButton<Locale>(
                                alignment: AlignmentDirectional.centerEnd,
                                underline: const SizedBox(),
                                value: settings.useSystemLanguage
                                    ? const Locale.fromSubtags()
                                    : settings.locale,
                                onChanged: (Locale? newValue) {
                                  settings.locale = newValue;
                                  I18n.of(context).locale = settings.locale;
                                  updateGameTheme();
                                  saveSettings();
                                  setState(() {});
                                },
                                items: <DropdownMenuItem<Locale>>[
                                  DropdownMenuItem<Locale>(
                                    value: const Locale.fromSubtags(),
                                    child: Text(
                                      () {
                                        String text = 'System default'.i18n;
                                        return text.length > 16
                                            ? text.substring(0, 14) + '…'
                                            : text;
                                      }(),
                                      style: TextStyle(
                                        fontSize: settings.smallerFont
                                            ? 20
                                            : 24,
                                        fontFamily: settings.font,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  ...supportedLocales.map<
                                    DropdownMenuItem<Locale>
                                  >(
                                    (value) => DropdownMenuItem<Locale>(
                                      value: value,
                                      child: Text(
                                        languageNames.containsKey(
                                              value.languageCode +
                                                  (value.countryCode != null
                                                      ? '_${value.countryCode}'
                                                      : ''),
                                            )
                                            ? languageNames[value.languageCode +
                                                  (value.countryCode != null
                                                      ? '_${value.countryCode}'
                                                      : '')]![1]
                                            : 'missing name',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _tile(
                          index: 7,
                          title: 'Export data'.i18n,
                          subtitle: 'Save your game and your settings in a backup file'
                              .i18n,
                          onTap: exportUserData,
                        ),
                        _tile(
                          index: 8,
                          title: 'Import data'.i18n,
                          subtitle: 'Restore your game and your settings from a backup file'
                              .i18n,
                          onTap: importUserData,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Settings entry with a title, a description and an action
  Widget _tile({
    required int index,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    color: focusItem == index ? Colors.white24 : Colors.white12,
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        onFocusChange: (bool focus) => setState(() {
          focus ? focusItem = index : null;
        }),
        title: Text(
          title,
          style: TextStyle(
            fontSize: settings.smallerFont ? 24 : 32,
            fontFamily: settings.font,
            color: Colors.white,
            height: 1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: settings.smallerFont ? 20 : 24,
            fontFamily: settings.font,
            color: Colors.white70,
            height: 1,
          ),
        ),
        onTap: onTap,
      ),
    ),
  );

  /// Write game data and settings in a file chosen by the player
  Future<void> exportUserData() async {
    Uri? file;
    try {
      file = await FilePicker.saveFile(
        dialogTitle: 'Export data'.i18n,
        fileName: backupFileName(),
        bytes: exportData(),
        mimeType: backupMimeType,
      );
    } catch (_) {
      _showMessage('Something went wrong.'.i18n);
      return;
    } finally {
      SystemChrome.restoreSystemUIOverlays();
    }
    if (file != null) _showMessage('Data exported.'.i18n);
  }

  /// Replace game data and settings with the content of a backup file
  Future<void> importUserData() async {
    if (!await _confirmImport()) return;
    PlatformFile? file;
    try {
      file = await FilePicker.pickFile(dialogTitle: 'Import data'.i18n);
    } catch (_) {
      _showMessage('Something went wrong.'.i18n);
      return;
    } finally {
      SystemChrome.restoreSystemUIOverlays();
    }
    if (file == null) return;

    final ImportError? error;
    try {
      error = importData(await file.readAsBytes());
    } catch (_) {
      _showMessage('Something went wrong.'.i18n);
      return;
    }
    if (error != null) {
      _showMessage(switch (error) {
        ImportError.notABackup => 'This is not a Xeonjia backup file.'.i18n,
        ImportError.unsupportedVersion =>
          'This backup file requires a newer version of the app.'.i18n,
        ImportError.corrupted => 'This backup file is damaged.'.i18n,
      });
      return;
    }

    _textFieldController.text = mainCharacter.name;
    if (mounted) I18n.of(context).locale = settings.locale;
    updateGameTheme();
    setState(() {});
    _showMessage('Data imported.'.i18n);
  }

  /// Ask the player before overwriting the current game
  Future<bool> _confirmImport() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Import data'.i18n,
          style: TextStyle(
            fontSize: settings.smallerFont ? 24 : 32,
            fontFamily: settings.font,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Your current game and your current settings will be lost.'.i18n,
          style: TextStyle(
            fontSize: settings.smallerFont ? 20 : 24,
            fontFamily: settings.font,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Discard'.i18n,
              style: TextStyle(
                color: Colors.white,
                fontSize: settings.smallerFont ? 20 : 24,
                fontFamily: settings.font,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Import data'.i18n,
              style: TextStyle(
                color: Colors.white,
                fontSize: settings.smallerFont ? 20 : 24,
                fontFamily: settings.font,
              ),
            ),
          ),
        ],
      ),
    );
    SystemChrome.restoreSystemUIOverlays();
    return confirmed ?? false;
  }

  /// Show the outcome of an import or an export
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: settings.smallerFont ? 20 : 24,
            fontFamily: settings.font,
            height: 1,
          ),
        ),
      ),
    );
  }

  void saveName(BuildContext context, String text) {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
    }
  }
}
