import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/utils/i18n.dart';

class ChooseName extends StatelessWidget {
  const ChooseName(this._textFieldController, this._formKey, this.saveName);
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
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Welcome!'.i18n,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Before starting tell me what you want to call your character.'
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 10),
                      child: insertNameForm(
                          _formKey, _textFieldController, saveName,
                          fontSize: 24),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).toggleableActiveColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () {
                        var names = [
                          'Aenor',
                          'Aldo',
                          'Anna',
                          'Aoi',
                          'Ave',
                          'Chi',
                          'Cora',
                          'Dag',
                          'Deborah',
                          'Eka',
                          'Enara',
                          'Ester',
                          'Katia',
                          'Koko',
                          'Kyo',
                          'Makana',
                          'Marko',
                        ];
                        _textFieldController.text =
                            names[Random().nextInt(names.length)].toUpperCase();
                      },
                      child: Text(
                        'Random name'.i18n,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
