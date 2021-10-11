import 'package:xeonjia/i18n/story.i18n.dart';

// Item in story mode (eg key, potion, stone, gem, ...)
class Item {
  // Item name
  final String _name;
  String _i18nName;
  String get name => _i18nName.toUpperCase();

  // Item ID
  String id;

  // Item description
  final String description;

  // Item location (tmx file) - only if keyItem == true
  final String location;

  // Item action (optional)
  final String action;

  // True if it is a special item that player can only obtain once
  final bool keyItem;

  Item(Map<String, dynamic> json)
      : _name = json['name'],
        description = json['description'],
        action = json['action'],
        keyItem = json['keyItem'] ?? false,
        location = json['location'] {
    _i18nName = _name.i18n;
  }
}
