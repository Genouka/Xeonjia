import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/util/screen_dimension.dart';

class DialogBox extends StatefulWidget {
  final _DialogBoxState state = _DialogBoxState();

  @override
  _DialogBoxState createState() => state;
}

class _DialogBoxState extends State<DialogBox> {
  // Messages to show
  List<Message> _messages = [];

  // Message currently displayed
  int _currentIndex;
  Message get currentMessage => active ? _messages[_currentIndex] : null;

  // True if this dialog box is visible
  bool get active => _messages.isNotEmpty;

  // If true, hide the map with a black container
  // eg. it is used for chapter change
  bool _hideMap;

  // Show one or more messages
  void setMessages(List<Message> newMessages, {bool hideMap = false}) {
    if (newMessages == null) return;
    _hideMap = hideMap;
    _messages.addAll(newMessages.fold([], (previousValue, element) {
      (previousValue as List<Message>).addAll(_splitMessage(element));
      return previousValue;
    }));
    _currentIndex = 0;
    if (mounted) setState(() {});
    game.pause(stopMusic: false);
    game.playSound(Sfx.dialog);
  }

  // Split message in sentences and group them
  List<Message> _splitMessage(Message message) {
    var strings = <String>[];
    RegExp(r'([^.,?!]*[.,?!]*)\s*').allMatches(message.text).forEach((m) {
      var match = m.group(0);
      (strings.isNotEmpty && strings.last.length + match.length < 90)
          ? strings.last += match
          : strings.add(match);
    });
    return strings.fold([], (previousValue, element) {
      previousValue.add(Message(element, message.authorName));
      return previousValue;
    });
  }

  // Show the next message or hide dialog box if there are no message to show
  void next() {
    if (++_currentIndex >= (_messages?.length ?? 0)) {
      _messages = [];
      game.resume();
    }
    game.playSound(Sfx.dialog);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: active,
      child: InkWell(
        onTap: next,
        child: Stack(
          children: [
            if (_hideMap ?? false) Container(color: Colors.black),
            Positioned(
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                width: screenSize.width - 40,
                height: 180,
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
          ],
        ),
      ),
    );
  }
}
