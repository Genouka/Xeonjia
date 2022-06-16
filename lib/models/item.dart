import 'package:xeonjia/i18n/story.i18n.dart';

// Item in story mode (eg key, potion, stone, gem, ...)
class Item {
  Item(Map<String, dynamic> json)
      : _name = json['name'],
        _description = json['description'],
        action = json['action'],
        keyItem = json['keyItem'] ?? false,
        location = json['location'];

  // Item name
  final String _name;
  String get name => _name.i18n.toUpperCase();

  // Item ID
  String? id;

  // Item description
  final String? _description;
  String? get description => _description?.i18n;

  // Item location (tmx file) - only if keyItem == true
  final String? location;

  // Item action
  final String? action;

  // True if it is a special item that player can only obtain once
  final bool keyItem;
}
