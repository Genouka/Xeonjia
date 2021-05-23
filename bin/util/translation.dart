class Translation {
  // File path
  String path;

  // Untranslated string
  String msgid;

  // Translated string
  String msgstr;

  // Translation comments
  String comments;

  Translation(this.path, this.msgid, this.msgstr, [this.comments = '']);

  @override
  bool operator ==(other) => msgid == other.msgid;
}
