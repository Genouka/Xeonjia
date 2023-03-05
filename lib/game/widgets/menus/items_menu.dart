import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/utils/little_scheme.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/widgets/boxes/info_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/utils/i18n.dart';

/// Menu that shows a list of [Item]s. Used for [ShopMenu] and [BackpackMenu]
abstract class ItemsMenu extends StatefulWidget {
  ItemsMenu(
    this.gameRef, {
    required this.text,
    required this.items,
    required this.onSelection,
    required this.onClose,
    this.showPrices = false,
  });
  final XeonjiaGame gameRef;
  final String text;
  final List<Item> items;
  final bool showPrices;
  final Function onSelection;
  final VoidCallback onClose;

  @override
  final GlobalKey<State<ItemsMenu>> key = GlobalKey();
  ItemsMenuState? get state => key.currentState as ItemsMenuState?;

  @override
  State<ItemsMenu> createState() => ItemsMenuState();
}

class ItemsMenuState extends State<ItemsMenu> {
  Item? selectedItem;
  int selectedItemIndex = 0;

  @override
  void initState() {
    selectedItem = widget.items.firstOrNull;
    super.initState();
  }

  /// Select the next item
  void nextItem() {
    setState(() {
      if (++selectedItemIndex < widget.items.length) {
        selectedItem = widget.items[selectedItemIndex];
      } else {
        selectedItemIndex = 0;
        selectedItem = widget.items.firstOrNull;
      }
    });
  }

  /// Select the previous item
  void previousItem() {
    setState(() {
      if (--selectedItemIndex < 0) selectedItemIndex = widget.items.length - 1;
      selectedItem = widget.items[selectedItemIndex];
    });
  }

  /// Choose the currently selected item
  void chooseItem([Item? i]) {
    setState(() {
      selectedItem = i ?? selectedItem;
      widget.gameRef.setMessage(Message(
        widget.gameRef,
        selectedItem!.description!,
        author: '${selectedItem!.rawName}/${selectedItem!.id}',
        xfaFile: 'items',
      ));
      widget.gameRef.environment
          .defineSymbol(Sym('selected-item-id'), selectedItem!.id);
      widget.gameRef.environment
          .defineSymbol(Sym('selected-item-name'), selectedItem!.name);
      widget.onSelection(selectedItem);
    });
  }

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
            bottom: 82,
          ),
          child: widget.items.isEmpty
              ? Container(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Center(child: Text('No items here'.i18n)))
              : ScrollConfiguration(
                  behavior: NoGlow(),
                  child: ListView(
                    shrinkWrap: true,
                    primary: true,
                    children: [
                      for (var i in widget.items)
                        InkWell(
                          onTap: () => chooseItem(i),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(selectedItem?.id == i.id ? '>' : ' '),
                                  Expanded(
                                      child: Text(i.name,
                                          textAlign: TextAlign.center)),
                                  Text(
                                    widget.showPrices
                                        ? '${i.price} ¤'
                                        : (i.keyItem
                                            ? '   '
                                            : ' x ${i.quantity}'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: widget.gameRef.playerOne!
                                                        .money >=
                                                    (i.price ?? -1)
                                                ? Colors.white
                                                : Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        _CloseButton(widget.gameRef, widget.onClose),
        InfoBox(
          onTap: null,
          opacity: 1,
          child: Text(
            widget.text.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
            maxLines: 1,
          ),
        ),
        InfoBox(
          onTap: null,
          opacity: 1,
          bottom: true,
          below: true,
          center: true,
          child: Text(
            '%s HP'.i18n.fill([widget.gameRef.playerOne!.hp.round()]) +
                '  /  ${widget.gameRef.playerOne!.money} ¤',
            style: Theme.of(context).textTheme.labelLarge,
            maxLines: 1,
          ),
        ),
      ]),
    );
  }
}

class _CloseButton extends StatelessWidget {
  _CloseButton(this.gameRef, this.onClose);
  final XeonjiaGame gameRef;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: InkWell(
        onTap: onClose,
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
                  style: Theme.of(context).textTheme.labelLarge,
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
