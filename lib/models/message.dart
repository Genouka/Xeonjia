// Message shown in dialog box
class Message {
  // Text of the message
  final String text;

  // Author (it could be authorName_mood)
  final String author;

  // Author image
  final String image;

  // Author name (author without mood)
  final String authorName;

  Message(this.text, [this.author])
      : image = author != null ? 'assets/images/heads/$author.png' : null,
        authorName = author?.split('_')?.first?.toUpperCase();
}
