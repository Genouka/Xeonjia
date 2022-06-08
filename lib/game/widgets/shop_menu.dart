import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/shop_item.dart';

// Menu used to buy items in stores
class ShopMenu extends StatefulWidget {
  final List<ShopItem> _items;
  const ShopMenu(this._items);

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
              child: Text(
                'Shop'.i18n.toUpperCase(),
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
          ),
          Text(
            'What do you need?'.i18n,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
          divider,
          Expanded(
            child: SizedBox(
              width: _width,
              child: ScrollConfiguration(
                behavior: _NoGlow(),
                child: ListView(
                  children: [
                    for (var item in widget._items)
                      ListTile(
                        title: Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        trailing: Text(
                          '${item.price} ¤',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: game.playerOne.money >= item.price
                                  ? Colors.white
                                  : Colors.red),
                        ),
                        onTap: game.playerOne.money >= item.price
                            ? () {
                                setState(() {
                                  game.playerOne.moneyDifference(-item.price,
                                      popup: false);
                                  game.executeAction(action: item.action);
                                });
                                game.refreshLifePointsBar();
                                closeMenu();
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
                style: Theme.of(context).textTheme.subtitle2),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: TextButton(
                onPressed: closeMenu,
                child: Text('Close'.i18n,
                    style: Theme.of(context).textTheme.headline2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void closeMenu() {
    game.overlays.remove('shop');
    game.setMessage(Message('Let me know if you need anything else.'.i18n,
        translate: false, author: 'pharmacist/elderly'));
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
