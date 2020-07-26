// Message shown in dialog box
class Message {
  // Text of the message
  final String text;

  // Author (it could be authorName_mood)
  final String _author;

  // Author image
  String get image => 'assets/images/$_author.png';

  // Author name (_author without mood)
  String get authorName => _author.split('_').first;

  Message(this.text, [this._author = 'npc']);
}