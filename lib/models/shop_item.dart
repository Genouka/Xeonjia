import 'package:xeonjia/util/i18n.dart';

// Item purchasable in stores
class ShopItem {
  ShopItem(this._name, {required this.action, required this.price});
  final String _name;
  String get name => _name.i18n;
  String action;
  int price;
}
