class Translation {
  Translation(this.path, this.msgid, this.msgstr, [this.comments = '']);

  // File path
  String path;

  // Untranslated string
  String msgid;

  // Translated string
  String? msgstr;

  // Translation comments
  String? comments;

  @override
  bool operator ==(other) => msgid == (other as Translation).msgid;

  @override
  int get hashCode => msgid.hashCode;
}
