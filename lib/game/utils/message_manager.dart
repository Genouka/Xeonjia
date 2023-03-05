import 'dart:ui';

import 'package:xeonjia/game/xeonjia.dart';

/// Manage game [Message]s (used in [DialogBox])
class MessageManager {
  MessageManager(this.gameRef);
  final XeonjiaGame gameRef;
  VoidCallback? callback;

  /// [Message]s to show
  List<Message> _messages = [];

  /// [Message] currently displayed
  int _currentIndex = 0;
  Message? get currentMessage => isActive ? _messages[_currentIndex] : null;
  void nextMessage() => _currentIndex++;

  /// Increase [_currentIndex] and check if there are other messages
  bool get hasOtherMessages =>
      _currentIndex + 1 < (gameRef.messageManager._messages.length);

  /// Answers shown at the end of the dialog
  List<Answer> answers = [];
  bool get isShowingAQuestion => !hasOtherMessages && answers.isNotEmpty;

  /// Remove every message
  void clear() {
    _messages = [];
    answers = [];
    gameRef.continueAction(delay: 0);
    callback?.call();
    callback = null;
    if (hideMap) {
      hideMap = false;
      gameRef.playBackgroundMusic();
    }
  }

  /// True if the dialog box is visible
  bool get isActive => _messages.isNotEmpty;

  /// If true, hide the map with a black container
  /// eg. it will be used for chapter change
  bool hideMap = false;

  /// Choose an answer
  void chooseAnswer(Answer answer) {
    gameRef.currentEventLog[answer.questionId] = answer.value;
    gameRef.messageManager.clear();
    gameRef.dialogBox.state!.next(removeAnswers: true);
  }

  /// Show one or more messages
  void setMessages(List<Message>? newMessages,
      {bool? hideMap, VoidCallback? callback}) {
    if (newMessages == null) return;
    this.hideMap = hideMap ?? false;
    this.callback = callback;
    _messages.addAll(newMessages.fold([], (previousValue, element) {
      (previousValue as List<Message>).addAll(_splitMessage(element));
      return previousValue;
    }));
    _currentIndex = 0;
    gameRef.dialogBox.state?.refresh();
    gameRef.pause(stopMusic: false);
  }

  /// Split message in sentences and group them
  List<Message> _splitMessage(Message message) {
    var strings = <String>[];
    RegExp(r'([^.,?!…。！？]*[.,?!»…。？！]*)\s*')
        .allMatches(message.text)
        .forEach((m) {
      var match = m.group(0);
      (strings.isNotEmpty &&
              !match!.contains(r'\n') &&
              (strings.last.length + match.length < 90 ||
                  (match.length < 3 && strings.isNotEmpty)))
          ? strings.last += match
          : strings.add(match!.replaceAll(r'\n', ''));
    });
    return strings.fold([], (previousValue, element) {
      previousValue.add(Message(
        gameRef,
        element,
        author: message.author,
        component: message.component,
        translate: false,
        font: message.font,
        xfaFile: message.xfaFile,
      ));
      return previousValue;
    });
  }
}
