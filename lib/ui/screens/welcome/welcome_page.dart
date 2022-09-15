import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/welcome/widgets/choose_name.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// Page shown on first startup
class WelcomePage extends StatelessWidget {
  WelcomePage([this.homePage]);
  final Widget? homePage;
  final _textFieldController = TextEditingController(text: mainCharacter.name);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: ChooseName(_textFieldController, _formKey, saveName),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () => saveName(_textFieldController.text, context),
                child: Text(
                  'OK'.i18n,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveName(String text, BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
      if (settings.firstRun) {
        settings.firstRun = false;
        saveSettings();
      }
      SystemChrome.restoreSystemUIOverlays();
      homePage == null
          ? Navigator.pop(context)
          : Navigator.pushReplacement(context, FadeRoute(homePage!));
    }
  }
}
