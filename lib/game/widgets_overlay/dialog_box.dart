import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';

class DialogBox extends StatefulWidget {
  final bool showImage = false;
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
      previousValue.add(Message(element, message.author));
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
            if (currentMessage != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: Colors.grey[800].withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                  child: Row(
                    children: [
                      if (widget.showImage)
                        Image.asset(
                          currentMessage.image,
                          height: 64,
                          width: 64,
                        ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentMessage.authorName + ' :',
                                style: const TextStyle(
                                  fontSize: 32,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                currentMessage.text,
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
