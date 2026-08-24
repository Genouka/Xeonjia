import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/home/home_page.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// Page shown on first startup
class WelcomePage extends StatelessWidget {
  final _textFieldController = TextEditingController(text: mainCharacter.name);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: null,
      body: DecoratedBox(
        decoration: gradientDecoration(),
        child: Container(
          color: Colors.black45,
          child: Center(
            child: ScrollConfiguration(
              behavior: NoGlow(),
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Welcome'.i18n,
                          style: TextStyle(
                            fontSize: 48,
                            fontFamily: settings.font,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Your journey is about to begin!\nWhat's your name?"
                              .i18n,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: settings.font,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: insertNameForm(
                            _formKey,
                            _textFieldController,
                            saveName,
                            context,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: TextButton(
                            onPressed: () =>
                                saveName(context, _textFieldController.text),
                            child: Text(
                              '> ' + "Let's start!".i18n,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontFamily: settings.font,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveName(BuildContext context, String text) {
    if (_formKey.currentState?.validate() ?? false) {
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
      if (settings.firstRun) {
        settings.firstRun = false;
        saveSettings();
      }
      SystemChrome.restoreSystemUIOverlays();
      Navigator.pushReplacement(context, FadeRoute(HomePage()));
    }
  }
}
