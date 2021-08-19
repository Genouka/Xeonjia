import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:xeonjia/i18n/ui.i18n.dart';
import 'package:xeonjia/game/util/little_scheme.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/item.dart';
import 'package:xeonjia/ui/themes.dart';

// Backpack menu
class BackpackMenu extends StatefulWidget {
  @override
  _BackpackMenuState createState() => _BackpackMenuState();
}

class _BackpackMenuState extends State<BackpackMenu> {
  String title;
  List<Widget> actions;
  Item selectedItem;

  @override
  void initState() {
    reloadInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 5, left: 25, right: 25),
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
          ),
          divider,
          Expanded(
            child: Center(
              child: selectedItem == null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView(
                        children: [
                          for (var i in items.entries)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedItem = i.key;
                                  reloadInfo();
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(i.key.keyItem ? '* ' : '${i.value} x '),
                                  Text(i.key.name),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: _NoGlow(),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            selectedItem.description,
                            style: Theme.of(context).textTheme.bodyText2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          divider,
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: Wrap(alignment: WrapAlignment.center, children: actions),
            ),
          ),
        ],
      ),
    );
  }

  Map<Item, int> get items => game.playerOne.backpackItems.fold({}, (p, e) {
        p[e] = p.containsKey(e) ? p[e] + 1 : 1;
        return p;
      });

  // Reload texts and buttons
  void reloadInfo() {
    if (selectedItem == null) {
      title = 'Backpack'.i18n;
      actions = [
        actionButton(
          'Back'.i18n.toUpperCase(),
          () {
            game.removeWidgetOverlay('backpackMenu');
            game.resume();
          },
        ),
      ];
    } else {
      title = selectedItem.name;
      actions = [
        if (selectedItem.action != null)
          actionButton(
            'Use'.i18n.toUpperCase(),
            () {
              setState(() {
                game.environment
                    .defineSymbol(Sym('selected-item-id'), selectedItem.id);
                game.environment
                    .defineSymbol(Sym('selected-item-name'), selectedItem.name);
                game.removeWidgetOverlay('backpackMenu');
                game.resume();
                game.executeAction(action: selectedItem.action);
              });
            },
          ),
        actionButton(
          'Back'.i18n.toUpperCase(),
          () {
            setState(() {
              selectedItem = null;
              reloadInfo();
            });
          },
        ),
      ];
    }
  }

  // White line that divides the children of the Column
  Widget get divider => Container(
        height: 3,
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: const BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      );

  // Button on the bottom row
  Widget actionButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: gameTheme.textTheme.bodyText2,
        ),
      ),
    );
  }
}

// Remove scroll glow
class _NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
