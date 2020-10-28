import 'package:flutter/material.dart';
import 'package:xeonjia/util/insert_name_form.dart';

class LastPage extends StatelessWidget {
  final TextEditingController _textFieldController;
  final GlobalKey<FormState> _formKey;

  LastPage(this._textFieldController, this._formKey);

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
                  child: insertNameForm(_formKey, _textFieldController),
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
                        const Text(
                          'Almost done!',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const Text(
                            'Before starting tell me your name which will be used in the game.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
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
