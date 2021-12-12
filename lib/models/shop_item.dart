import 'package:flutter/foundation.dart';
import 'package:xeonjia/i18n/story.i18n.dart';

// Item purchasable in stores
class ShopItem {
  final String _name;
  String get name => _name.i18n;
  String action;
  int price;
  ShopItem(this._name, {@required this.action, @required this.price});
}
