import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/ui/themes.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/latinise.dart';

/// Page route
class FadeRoute extends PageRouteBuilder {
  FadeRoute(this.page)
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(opacity: animation, child: child),
        );

  @override
  final Duration transitionDuration = const Duration(milliseconds: 150);

  final Widget page;
}

/// This removes scroll glow
class NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

/// Button used in pauseMenu and backpackMenu
Widget actionButton(String text, VoidCallback onPressed) => InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: gameTheme.textTheme.bodyText2,
        ),
      ),
    );

/// White line that divides children of Columns in pauseMenu and backpackMenu
Widget divider(BuildContext context) => Container(
      height: 3,
      width: MediaQuery.of(context).size.width / 1.5,
      decoration: const BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    );

/// Form used to insert player name
Widget insertNameForm(GlobalKey<FormState> key,
    TextEditingController textFieldController, Function onSubmitted,
    {double? fontSize}) {
  return Form(
    key: key,
    child: TextFormField(
      textAlign: TextAlign.center,
      controller: textFieldController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      style: TextStyle(fontSize: fontSize),
      onFieldSubmitted: (String text) {
        onSubmitted(text.trim());
        SystemChrome.restoreSystemUIOverlays();
      },
      onChanged: (String input) {
        if (input.isEmpty) key.currentState?.validate();
      },
      validator: (value) {
        if (value == '') return "What's your name?".i18n + ' [A-Z]';
        return value!.trim().length < 2 ? 'Too short.'.i18n : null;
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        LatiniseAndUpperCaseTextFormatter(),
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
      ],
      decoration: InputDecoration(
        hintText: 'Insert your name here'.i18n,
        hintStyle: const TextStyle(fontSize: 18),
      ),
    ),
  );
}

/// Replace special characters and uppercase the input
class LatiniseAndUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.latinise();
    return TextEditingValue(
      text: text.toUpperCase(),
      selection: text.length != newValue.text.length
          ? TextSelection.collapsed(offset: text.length)
          : newValue.selection,
    );
  }
}
