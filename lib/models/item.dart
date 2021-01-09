import 'package:xeonjia/i18n/story.i18n.dart';

// Item in story mode (eg key, potion, stone, gem, ...)
class Item {
  // Item name
  final String _name;
  String get name => _name.i18n.toUpperCase();

  // Item description
  final String description;

  // Item location (tmx file)
  final String location;

  Item(Map<String, dynamic> json)
      : _name = json['name'],
        description = json['description'],
        location = json['location'];
}
