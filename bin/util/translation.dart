class Translation {
  // File path
  String path;

  // Untranslated string
  String msgid;

  // Translated string
  String msgstr;

  Translation(this.path, this.msgid, this.msgstr);

  @override
  bool operator ==(other) => msgid == other.msgid;
}
