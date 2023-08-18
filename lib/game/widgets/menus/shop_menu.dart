import 'package:xeonjia/game/xeonjia.dart';

/// Menu used to buy [Item]s in stores
class ShopMenu extends ItemsMenu {
  ShopMenu(XeonjiaGame gameRef, List<Item> items, {bool machine = false})
      : super(
          gameRef,
          text: machine ? 'HP Machine'.i18n : 'Shop'.i18n,
          items: items,
          showPrices: true,
          onSelection: (Item item) {
            if (gameRef.playerOne!.money >= item.price!) {
              // i18n: "Do you want to buy {{selected-item-name}}?".i18n
              // i18n: "Do I buy {{selected-item-name}}?".i18n
              String dialogMessage = machine
                  ? '"Do I buy {{selected-item-name}}?"'
                  : '"pharmacist/elderly" "Do you want to buy {{selected-item-name}}?"';
              gameRef.executeAction(action: '''
                  (begin
                    (dialog '(($dialogMessage)))
                    (define id "generic-question")
                    (answer id '(("Yes" . #t) ("No" . #f)))
                    (wait)
                    (if (get id)
                      (begin
                        (remove-overlay "shopMenu")
                        (set-money-diff ${-item.price!})
                        ${item.action!})))''');
            } else {
              gameRef.setMessage(Message(
                  gameRef, "I don't have enough money for this item.".i18n,
                  translate: false));
            }
          },
          onClose: () {
            gameRef.overlays.remove('shopMenu');
            if (!machine) {
              gameRef.setMessage(Message(
                  gameRef, 'Let me know if you need anything else.'.i18n,
                  translate: false, author: 'pharmacist/elderly'));
            }
            gameRef.resume();
          },
        );
}
