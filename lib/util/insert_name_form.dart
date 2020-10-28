import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Form used to insert player name
Widget insertNameForm(
    GlobalKey key, TextEditingController textFieldController) {
  return Form(
    key: key,
    child: TextFormField(
        textAlign: TextAlign.center,
        controller: textFieldController,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == '') return "What's your name?";
          return value.trim().length < 2 ? 'Too short' : null;
        },
        inputFormatters: [LengthLimitingTextInputFormatter(10)],
        decoration: const InputDecoration(hintText: 'Insert your name here')),
  );
}
