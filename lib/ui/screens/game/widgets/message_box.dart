import 'dart:async';
import 'package:flutter/material.dart';

import 'package:xeonjia/util/screen_dimension.dart';

class MessageBox extends StatefulWidget {
  final _MessageBoxState state = _MessageBoxState();

  @override
  _MessageBoxState createState() => state;
}

class _MessageBoxState extends State<MessageBox> {
  // Message displayed
  String _message;
  String get message => _message;
  set message(String newMessage) {
    _message = newMessage;
    if (mounted) {
      setState(() {});
    }
    Timer(const Duration(seconds: 3), () {
      dismiss();
    });
  }

  // Clear message and hide message box
  void dismiss() {
    message = null;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _message != null,
      child: Positioned(
        bottom: 0,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          width: screenSize.width - 40,
          decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: ListTile(
            leading: const CircleAvatar(),
            title: Text(
              _message ?? '',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
