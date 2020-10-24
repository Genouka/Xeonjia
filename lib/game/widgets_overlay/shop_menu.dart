import 'package:flutter/material.dart';

import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/shop_item.dart';

// Menu used to buy items in stores
class ShopMenu extends StatefulWidget {
  final List<ShopItem> _items;
  ShopMenu(this._items);

  @override
  _ShopMenuState createState() => _ShopMenuState();
}

class _ShopMenuState extends State<ShopMenu> {
  double _width;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width / 1.5;
    return Container(
      color: Colors.black87,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: _width,
              alignment: Alignment.bottomCenter,
              child: const Text(
                'SHOP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          const Text(
            'What do you need?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              letterSpacing: 1.4,
            ),
          ),
          divider,
          Expanded(
            child: Container(
              width: _width,
              child: ScrollConfiguration(
                behavior: _NoGlow(),
                child: ListView(
                  children: [
                    for (var item in widget._items)
                      ListTile(
                        title: Text(item.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 32)),
                        trailing: Text(
                          '${item.price} ¤',
                          style: TextStyle(
                              color: game.playerOne.money >= item.price
                                  ? Colors.white
                                  : Colors.red,
                              fontSize: 32),
                        ),
                        onTap: game.playerOne.money >= item.price
                            ? () {
                                setState(() {
                                  game.executeAction(item.action);
                                });
                                game.refreshLifePointsBar();
                              }
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
          divider,
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text(
                '${game.playerOne.lifePoints.round()} LP  -  ${game.playerOne.money} ¤',
                style: const TextStyle(color: Colors.white, fontSize: 40)),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: FlatButton(
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    letterSpacing: 1.4,
                  ),
                ),
                onPressed: () {
                  game.removeWidgetOverlay('shop');
                  game.setMessage(Message(
                      'Let me know if you need anything else.',
                      author: 'pharmacist/elderly'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // White line that divides the children of the Column
  Widget get divider => Container(
        height: 3,
        width: _width,
        decoration: const BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      );
}

// Remove scroll glow
class _NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
