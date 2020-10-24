import 'package:xeonjia/game/components/abstract_basic.dart';

// Message shown in dialog box
class Message {
  // Text of the message
  final String text;

  // Author (displayName/name_mood)
  // If displayName is omitted: name is used
  // If name is omitted: component.name is used
  // If mood is omitted: no mood
  // Examples: mom, mom/_happy, ???/girl, ???/girl_happy, /sad, /hero, /hero_sad
  // '>' is used for thoughts and narrator voice
  String author;

  // Author image
  String image;

  // Author name (name displayed)
  String authorName;

  // Character speaking
  BasicComponent component;

  Message(this.text, {this.author = '', this.component}) {
    var m = RegExp(r'([^\/]*)\/?([^_]*)_?(.*)').firstMatch(author);
    var name = m.group(2) != '' ? m.group(2) : component?.name ?? '>';
    authorName = (m.group(1) != '' ? m.group(1) : name).toUpperCase();
    var mood = m.group(3);
    var fileName = name + (mood != '' ? '_$mood' : '');
    image = authorName != '>' ? 'assets/images/heads/${fileName}.png' : null;
  }
}
