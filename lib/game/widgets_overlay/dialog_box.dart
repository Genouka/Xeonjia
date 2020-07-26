import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/util/screen_dimension.dart';

class DialogBox extends StatefulWidget {
  final _DialogBoxState state = _DialogBoxState();

  @override
  _DialogBoxState createState() => state;
}

class _DialogBoxState extends State<DialogBox> {
  // Messages to show
  List<Message> _messages;

  // Message currently displayed
  int _currentIndex;
  Message get currentMessage => active ? _messages[_currentIndex] : null;

  // True if this dialog box is visible
  bool get active => _messages != null;

  // Show one or more messages
  void setMessages(List<Message> newMessages) {
    if (newMessages == null) return;
    _messages = newMessages;
    _currentIndex = 0;
    if (mounted) setState(() {});
    game.pause();
  }

  // Show the next message or hide dialog box if there are no message to show
  void next() {
    if (++_currentIndex >= (_messages?.length ?? 0)) {
      _messages = null;
      game.resume();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: active,
      child: Positioned(
        bottom: 0,
        child: InkWell(
          onTap: next,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            width: screenSize.width - 40,
            height: 140,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: ListTile(
              leading: currentMessage?.image != null
                  ? CircleAvatar(child: Image.asset(currentMessage?.image))
                  : null,
              title: Text(
                (currentMessage?.authorName ?? '') + ':',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                currentMessage?.text ?? '',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
