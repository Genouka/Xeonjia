import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xeonjia/utils/i18n.dart';
import 'package:xeonjia/utils/latinise.dart';
import 'package:xeonjia/utils/local_data_controller.dart';

/// Page route
class FadeRoute extends PageRouteBuilder {
  FadeRoute(this.page)
    : super(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) => page,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) => FadeTransition(opacity: animation, child: child),
      );

  @override
  final Duration transitionDuration = const Duration(milliseconds: 150);

  final Widget page;
}

/// This removes scroll glow
class NoGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// Gradient decoration used in HomePage, SettingsPage, InfoPage, WelcomePage
BoxDecoration gradientDecoration({bool withOpacity = false}) => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(withOpacity ? 0x85306684 : 0xFF306684),
      const Color(0xFFC1D5DE),
    ],
  ),
);

/// Close button in settings and info pages
TextButton closeButton(
  BuildContext context,
  ValueChanged<bool>? onFocusChange,
) => TextButton(
  onFocusChange: onFocusChange,
  style: ButtonStyle(
    overlayColor: WidgetStateColor.resolveWith((states) => Colors.white24),
  ),
  onPressed: () => Navigator.of(context).pop(),
  child: const Text(
    '×',
    style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'dd5x7'),
  ),
);

/// Form used to insert player name
Widget insertNameForm(
  GlobalKey<FormState> key,
  TextEditingController textFieldController,
  Function onSubmitted,
  BuildContext context, {
  double? fontSize = 32,
}) {
  return Form(
    key: key,
    child: TextFormField(
      textAlign: TextAlign.center,
      controller: textFieldController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      style: TextStyle(fontSize: fontSize, fontFamily: settings.font),
      onFieldSubmitted: (String text) {
        onSubmitted(context, text.trim());
        SystemChrome.restoreSystemUIOverlays();
      },
      onChanged: (String input) {
        if (input.isEmpty) key.currentState?.validate();
      },
      validator: (value) {
        if (value == '') return 'Valid characters: A-Z.'.i18n;
        return value!.trim().length < 2 ? 'Too short.'.i18n : null;
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        LatiniseAndUpperCaseTextFormatter(),
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
      ],
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Insert your name'.i18n,
        hintStyle: TextStyle(fontSize: 32, fontFamily: settings.font),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorStyle: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontFamily: settings.font,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    ),
  );
}

/// Replace special characters and uppercase the input
class LatiniseAndUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.latinise();
    return TextEditingValue(
      text: text.toUpperCase(),
      selection: text.length != newValue.text.length
          ? TextSelection.collapsed(offset: text.length)
          : newValue.selection,
    );
  }
}
