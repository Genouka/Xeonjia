import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/i18n/util.i18n.dart';

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
          if (value == '') return "What's your name?".i18n;
          return value.trim().length < 2 ? 'Too short.'.i18n : null;
        },
        inputFormatters: [
          _UpperCaseTextInputFormatter(),
          LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
        ],
        decoration: InputDecoration(hintText: 'Insert your name here'.i18n)),
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
