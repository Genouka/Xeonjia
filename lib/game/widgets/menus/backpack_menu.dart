import 'package:flutter/material.dart';
import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/utils/little_scheme.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/utils/i18n.dart';

// Backpack menu
class BackpackMenu extends StatefulWidget {
  BackpackMenu(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  State<BackpackMenu> createState() => _BackpackMenuState();
}

class _BackpackMenuState extends State<BackpackMenu> {
  late String title;
  late List<Widget> actions;
  Item? selectedItem;

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
          divider(context),
          Expanded(
            child: Center(
              child: selectedItem == null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView(
                        shrinkWrap: true,
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
                            ),
                          if (items.entries.isEmpty)
                            Center(child: Text('No items here'.i18n))
                        ],
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: NoGlow(),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            selectedItem!.description!,
                            style: Theme.of(context).textTheme.bodyText2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          divider(context),
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

  Map<Item, int> get items =>
      widget.gameRef.playerOne!.backpackItems.fold({}, (p, e) {
        p[e] = p.containsKey(e) ? p[e]! + 1 : 1;
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
            widget.gameRef.overlays.remove('backpackMenu');
            widget.gameRef.resume();
          },
        ),
      ];
    } else {
      title = selectedItem!.name;
      actions = [
        if (selectedItem!.action != null)
          actionButton(
            'Use'.i18n.toUpperCase(),
            () {
              setState(() {
                widget.gameRef.environment
                    .defineSymbol(Sym('selected-item-id'), selectedItem!.id!);
                widget.gameRef.environment.defineSymbol(
                    Sym('selected-item-name'), selectedItem!.name);
                widget.gameRef.overlays.remove('backpackMenu');
                widget.gameRef.resume();
                widget.gameRef.executeAction(action: selectedItem!.action!);
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
}
