import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';

// Manage game messages (used in dialog box)
class MessageManager {
  // Messages to show
  List<Message> _messages = [];

  // Message currently displayed
  int _currentIndex;
  Message get currentMessage => active ? _messages[_currentIndex] : null;
  void nextMessage() => _currentIndex++;

  // Increase currentIndex and check if there are other messages
  bool get hasOtherMessages =>
      _currentIndex + 1 < (game.messageManager._messages?.length ?? 0);

  // Answers shown at the end of the dialog
  List<Answer> answers = [];
  bool get isShowingAQuestion => !hasOtherMessages && answers.isNotEmpty;

  // Remove every message
  void clear() {
    _messages = [];
    answers = [];
    game.resumeEngine();
    game.continueAction(delay: 0);
    if (hideMap) {
      hideMap = false;
      game.playBackgroundMusic();
    }
  }

  // True if the dialog box is visible
  bool get active => _messages.isNotEmpty;

  // If true, hide the map with a black container
  // eg. it will be used for chapter change
  bool hideMap = false;

  // Show one or more messages
  void setMessages(List<Message> newMessages, {bool hideMap}) {
    if (newMessages == null) return;
    this.hideMap = (hideMap ?? false);
    _messages.addAll(newMessages.fold([], (previousValue, element) {
      (previousValue as List<Message>).addAll(_splitMessage(element));
      return previousValue;
    }));
    _currentIndex = 0;
    game.dialogBox.state?.refresh();
    game.pause(stopMusic: false);
    game.playSound(Sfx.dialog);
  }

  // Split message in sentences and group them
  List<Message> _splitMessage(Message message) {
    var strings = <String>[];
    RegExp(r'([^.,?!"»…]*[.,?!"»…]*)\s*').allMatches(message.text).forEach((m) {
      var match = m.group(0);
      (strings.isNotEmpty &&
              !match.contains('\\n') &&
              (strings.last.length + match.length < 90 ||
                  (match.length < 3 && strings.isNotEmpty)))
          ? strings.last += match
          : strings.add(match.replaceAll('\\n', ''));
    });
    return strings.fold([], (previousValue, element) {
      previousValue.add(Message(
        element,
        author: message.author,
        component: message.component,
        translate: false,
        font: message.font,
      ));
      return previousValue;
    });
  }
}
