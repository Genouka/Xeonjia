import 'package:flutter/foundation.dart';

// Item purchasable in stores
class ShopItem {
  String name;
  String action;
  int price;
  ShopItem({@required this.name, @required this.action, @required this.price});
}
