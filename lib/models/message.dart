// Message shown in dialog box
class Message {
  // Text of the message
  final String text;

  // Author (it could be authorName_mood)
  final String author;

  // Author image
  String get image => 'assets/images/$author.png';

  // Author name (_author without mood)
  String get authorName => author.split('_').first.toUpperCase();

  Message(this.text, [this.author = 'npc']);
}
