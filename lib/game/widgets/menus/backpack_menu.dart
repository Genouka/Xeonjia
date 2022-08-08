import 'package:flutter/material.dart';
import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/utils/little_scheme.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/widgets/boxes/info_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

// Backpack menu
class BackpackMenu extends StatefulWidget {
  BackpackMenu(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  State<BackpackMenu> createState() => _BackpackMenuState();
}

class _BackpackMenuState extends State<BackpackMenu> {
  Item? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width / 7,
            right: MediaQuery.of(context).size.width / 7,
            top: 60,
          ),
          child: ListView(
            shrinkWrap: true,
            primary: true,
            children: [
              for (var i in items.entries)
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedItem = i.key;
                      widget.gameRef.setMessage(
                          Message(widget.gameRef, selectedItem!.description!));
                      widget.gameRef.environment.defineSymbol(
                          Sym('selected-item-id'), selectedItem!.id!);
                      widget.gameRef.environment.defineSymbol(
                          Sym('selected-item-name'), selectedItem!.name);
                      // i18n: "Do you want to use {{selected-item-name}}?".i18n
                      if (selectedItem!.action != null) {
                        widget.gameRef.executeAction(action: '''
                        (begin
                          (dialog '(("Do you want to use {{selected-item-name}}?")))
                          (define id "generic-question")
                          (answer id '(("Yes" . #t) ("No" . #f)))
                          (wait)
                          (if (get id)
                            (begin
                              (remove-overlay "backpackMenu")
                              ${selectedItem!.action!})))''');
                      }
                    });
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedItem?.id == i.key.id ? '>' : ' '),
                          Expanded(
                              child: Text(i.key.name,
                                  textAlign: TextAlign.center)),
                          Text(i.key.keyItem ? '   ' : ' x ${i.value}'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              if (items.entries.isEmpty)
                Center(child: Text('No items here'.i18n))
            ],
          ),
        ),
        _CloseButton(widget.gameRef),
        InfoBox(
          onTap: null,
          opacity: 1,
          child: Text(
            'Backpack'.i18n.toUpperCase(),
            style: Theme.of(context).textTheme.button,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ]),
    );
  }

  Map<Item, int> get items =>
      widget.gameRef.playerOne!.backpackItems.fold({}, (p, e) {
        p[e] = p.containsKey(e) ? p[e]! + 1 : 1;
        return p;
      })
        ..addAll({
          Item({
            'id': 'gems_*',
            'name': 'Gems'.i18n,
            'description': 'Mysterious gems scattered around the world.'.i18n
          }): widget.gameRef.playerOne!.gemCount
        });
}

class _CloseButton extends StatelessWidget {
  _CloseButton(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: InkWell(
        onTap: () {
          gameRef.overlays.remove('backpackMenu');
          gameRef.resume();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          height: 36,
          width: MediaQuery.of(context).size.width / 2.2,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: const BorderRadius.all(Radius.circular(30))),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Close'.i18n.toUpperCase(),
                  style: Theme.of(context).textTheme.button,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const Icon(Icons.close, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
