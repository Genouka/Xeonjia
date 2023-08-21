import 'package:flutter/material.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/settings/resources/option_list.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

class SettingsPage extends StatefulWidget {
  static State<SettingsPage> of(BuildContext context) =>
      context.findAncestorStateOfType()!;

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Settings'.i18n.toUpperCase()),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w600,
          fontFamily: settings.font,
        ),
        leading: Container(),
        actions: [closeButton(context)],
      ),
      body: OptionList());
  void refresh() => setState(() {});
}
