import 'package:flutter/material.dart';
import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/util/insert_name_form.dart';

class LastPage extends StatelessWidget {
  const LastPage(this._textFieldController, this._formKey, this.saveName);

  final TextEditingController _textFieldController;
  final GlobalKey<FormState> _formKey;
  final Function saveName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 60, bottom: 60),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 100, right: 100),
                  child:
                      insertNameForm(_formKey, _textFieldController, saveName),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Almost done!'.i18n,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Before starting tell me your name which will be used in the game.'
                                .i18n,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
