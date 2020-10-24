import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';

class DialogBox extends StatefulWidget {
  final _DialogBoxState state = _DialogBoxState();

  @override
  _DialogBoxState createState() => state;
}

class _DialogBoxState extends State<DialogBox> with TickerProviderStateMixin {
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

  // Typing text animation controller
  AnimationController _controller;
  Animation<int> _characterCount;
  final int _timePerChar = 35;

  // Show one or more messages
  void setMessages(List<Message> newMessages, {bool hideMap = false}) {
    if (newMessages == null) return;
    _hideMap = hideMap;
    _messages.addAll(newMessages.fold([], (previousValue, element) {
      (previousValue as List<Message>).addAll(_splitMessage(element));
      return previousValue;
    }));
    _currentIndex = 0;
    _animateText();
    if (mounted) setState(() {});
    game.pause(stopMusic: false);
    game.playSound(Sfx.dialog);
  }

  // Split message in sentences and group them
  List<Message> _splitMessage(Message message) {
    var strings = <String>[];
    RegExp(r'([^.,?!]*[.,?!]*)\s*').allMatches(message.text).forEach((m) {
      var match = m.group(0);
      (strings.isNotEmpty && strings.last.length + match.length < 90 ||
              match.isEmpty)
          ? strings.last += match
          : strings.add(match);
    });
    return strings.fold([], (previousValue, element) {
      previousValue.add(Message(element,
          author: message.author, component: message.component));
      return previousValue;
    });
  }

  // Show the next message or hide dialog box if there are no message to show
  void next() {
    if (_controller?.isAnimating ?? false) {
      _controller.fling();
      return;
    }
    if (++_currentIndex >= (_messages?.length ?? 0)) {
      _messages = [];
      game.resume();
    } else {
      _animateText();
    }
    game.playSound(Sfx.dialog);
    if (mounted) setState(() {});
  }

  // Typing text animation
  void _animateText() {
    if (_controller?.isAnimating ?? false) return;
    _controller = AnimationController(
      duration:
          Duration(milliseconds: _timePerChar * currentMessage.text.length),
      vsync: this,
    );
    _characterCount = StepTween(begin: 0, end: currentMessage.text.length)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.forward().then((_) => _controller.dispose());
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (currentMessage.image != null)
                        Image.asset(
                          currentMessage.image,
                          height: 96,
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.none,
                        ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((currentMessage.authorName ?? '>') != '>')
                                Text(
                                  currentMessage.authorName + ' :',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              AnimatedBuilder(
                                animation: _characterCount,
                                builder: (BuildContext context, Widget child) {
                                  var text = currentMessage.text
                                      .substring(0, _characterCount.value);
                                  return Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                    ),
                                  );
                                },
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
