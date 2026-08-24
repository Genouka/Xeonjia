import 'package:xeonjia/utils/i18n.dart';

/// Item in story mode (eg key, potion, stone, gem, ...)
class Item {
  Item(Map<String, dynamic> json)
    : _name = json['name'],
      _description = json['description'],
      action = json['action'],
      keyItem = json['keyItem'] ?? false,
      location = json['location'],
      price = json['price'],
      quantity = json['quantity'],
      id = json['id'];

  /// Item name
  final String _name;
  String get name => _name.i18n.toUpperCase();
  String get rawName => _name;

  /// Item ID
  String id;

  /// Item description
  final String? _description;
  String? get description => _description?.i18n;

  /// Item location (tmx file) - only if keyItem == true
  final String? location;

  /// Item action
  final String? action;

  /// True if it is a special item that player can only obtain once
  final bool keyItem;

  /// Price, used for items purchasable in stores
  int? price;

  /// Quantity, used for backpack
  int? quantity;

  Map<String, dynamic> toMap() => {
    'name': _name,
    'description': _description,
    'action': action,
    'keyItem': keyItem,
    'location': location,
    'price': price,
    'quantity': quantity,
    'id': id,
  };

  @override
  bool operator ==(Object other) => other is Item && other.name == name;

  @override
  int get hashCode => _name.hashCode;
}
