import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Form used to insert player name
Widget insertNameForm(GlobalKey key, TextEditingController textFieldController,
    Function onSubmitted) {
  return Form(
    key: key,
    child: TextFormField(
        textAlign: TextAlign.center,
        controller: textFieldController,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (String text) {
          onSubmitted(text?.trim());
          SystemChrome.restoreSystemUIOverlays();
        },
        validator: (value) {
          if (value == '') return "What's your name?";
          return value.trim().length < 2 ? 'Too short.' : null;
        },
        inputFormatters: [
          _UpperCaseTextInputFormatter(),
          LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
        ],
        decoration: const InputDecoration(hintText: 'Insert your name here')),
  );
}

class _UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
