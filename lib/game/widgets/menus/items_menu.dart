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
  State<ItemsMenu> createState() => _ItemsMenuState();
}

class _ItemsMenuState extends State<ItemsMenu> {
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
                          onTap: () {
                            setState(() {
                              selectedItem = i;
                              widget.gameRef.setMessage(Message(
                                widget.gameRef,
                                selectedItem!.description!,
                                author:
                                    '${selectedItem!.rawName}/${selectedItem!.id}',
                                xfaFile: 'items',
                              ));
                              widget.gameRef.environment.defineSymbol(
                                  Sym('selected-item-id'), selectedItem!.id);
                              widget.gameRef.environment.defineSymbol(
                                  Sym('selected-item-name'),
                                  selectedItem!.name);
                              widget.onSelection(selectedItem);
                              setState(() {});
                            });
                          },
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
