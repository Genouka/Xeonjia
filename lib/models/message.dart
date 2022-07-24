import 'package:flame/sprite.dart';
import 'package:xeonjia/game/components/abstract_basic.dart';
import 'package:xeonjia/game/util/fire_atlas.dart';
import 'package:xeonjia/game/util/little_scheme.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/util/i18n.dart';
import 'package:xeonjia/util/local_data_controller.dart';

// Message shown in dialog box
class Message {
  Message(this.gameRef, this.text,
      {this.author = '', this.component, bool translate = true, this.font}) {
    var m = RegExp(r'([^\/]*)\/?([^_]*)_?(.*)').firstMatch(author)!;
    var name = m.group(2) != '' ? m.group(2)! : component?.name ?? '';
    authorName = m.group(1) != '' ? m.group(1)! : (author == '' ? '' : name);
    var mood = m.group(3);
    var headName = name + (mood != '' ? '_$mood' : '');
    if (authorName != '') {
      authorName = (authorName == 'hero')
          ? mainCharacter.name
          : authorName.i18n.replaceAll('-', ' ');
      gameRef.loadCustomAtlas('images/metadata/heads.xfa').then((value) {
        sprite = value.getSprite(headName);
      });
    }
    if (translate) {
      text = text
          .replaceAll(r'\n', '\n')
          .i18n
          .replaceAll('\n', r'\n')
          .replaceAllMapped(RegExp('{{(.*?)}}'),
              (m) => gameRef.environment.lookForValue(Sym(m[1]!)).toString());
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

  // Current game
  final XeonjiaGame gameRef;

  // Text of the message
  String text;

  // Author (name/avatar_mood)
  // If name is omitted: avatar name is used
  // If avatar is omitted: component.name is used
  // If mood is omitted: no mood
  // Examples: mom, mom/_happy, bob/man, ali/girl_happy, /_sad, /hero, /hero_sad
  // Default name and default avatar: /
  // Author empty (author == '') is used for thoughts and narrator voice
  String author;

  // Author's sprite
  Sprite? sprite;

  // Author name (displayed name)
  late String authorName;

  // Speaking component
  BasicComponent? component;

  // Font family used (null if default)
  String? font;
}

// Answer shown in dialogs
class Answer {
  Answer(this.questionId, this.text, this.value);

  // Unique ID saved in the event log
  String questionId;

  // Displayed text
  String text;

  // Answer value
  dynamic value;
}
