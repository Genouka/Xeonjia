import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/util/little_scheme.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/i18n/story.i18n.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Message shown in dialog box
class Message {
  // Text of the message
  String text;

  // Author (name/avatar_mood)
  // If name is omitted: avatar name is used
  // If avatar is omitted: component.name is used
  // If mood is omitted: no mood
  // Examples: mom, mom/_happy, bob/man, ali/girl_happy, /_sad, /hero, /hero_sad
  // Default name and default avatar: /
  // Author null or '' is used for thoughts and narrator voice
  String author;

  // Author image
  String image;

  // Author name (name displayed)
  String authorName;

  // Character speaking
  BasicComponent component;

  // Font family used (null if default)
  String font;

  Message(this.text,
      {this.author = '', this.component, bool translate = true, this.font}) {
    var m = RegExp(r'([^\/]*)\/?([^_]*)_?(.*)').firstMatch(author);
    var name = m.group(2) != '' ? m.group(2) : component?.name ?? '';
    authorName = (m.group(1) != '' ? m.group(1) : (author == '' ? '' : name));
    var mood = m.group(3);
    var fileName = name + (mood != '' ? '_$mood' : '');
    image = authorName != '' ? 'assets/images/heads/$fileName.png' : null;
    if (authorName != '') {
      authorName = (authorName == 'hero')
          ? mainCharacter.name
          : authorName.i18n.replaceAll('-', ' ');
    }
    if (translate) {
      text = text
          .replaceAll('\\n', '\n')
          .i18n
          .replaceAll('\n', '\\n')
          .replaceAllMapped(RegExp(r'{{(.*?)}}'),
              (m) => game.environment.lookForValue(Sym(m[1])).toString());
      if (font == 'kobi') {
        const diacritics =
            'ÀÁÂÃÄÅàáâãäåắạÒÓÔÕÕÖØòóôõöøốọồớÈÉÊËèéêëềẽðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüựứừưÑñŠšŸÿýŽžđ';
        const nonDiacritics =
            'AAAAAAaaaaaaaaOOOOOOOooooooooooEEEEeeeeeeeCcDIIIIiiiiUUUUuuuuuuuuNnSsYyyZzd';
        text = text.splitMapJoin('',
            onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
                ? nonDiacritics[diacritics.indexOf(char)]
                : char);
      }
    }
  }
}

// Answer shown in dialogs
class Answer {
  // Unique ID saved in the event log
  String questionId;

  // Text displayed
  String text;

  // Answer value
  dynamic value;

  Answer(this.questionId, this.text, this.value);
}
