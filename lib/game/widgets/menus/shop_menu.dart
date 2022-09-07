import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/widgets/menus/items_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

/// Menu used to buy [Item]s in stores
class ShopMenu extends ItemsMenu {
  ShopMenu(XeonjiaGame gameRef, List<Item> items)
      : super(
          gameRef,
          text: 'Shop'.i18n,
          items: items,
          showPrices: true,
          onSelection: (Item item) {
            if (gameRef.playerOne!.money >= item.price!) {
              // i18n: "Do you want to buy {{selected-item-name}}?".i18n
              gameRef.executeAction(action: '''
                  (begin
                    (dialog '(("pharmacist/elderly" "Do you want to buy {{selected-item-name}}?")))
                    (define id "generic-question")
                    (answer id '(("Yes" . #t) ("No" . #f)))
                    (wait)
                    (if (get id)
                      (begin
                        (remove-overlay "shop")
                        (set-money-diff ${-item.price!})
                        ${item.action!})))''');
            } else {
              gameRef.setMessage(Message(
                  gameRef, "I don't have enough money for this item.".i18n,
                  author: '/hero_sad', translate: false));
            }
          },
          onClose: () {
            gameRef.overlays.remove('shop');
            gameRef.setMessage(Message(
                gameRef, 'Let me know if you need anything else.'.i18n,
                translate: false, author: 'pharmacist/elderly'));
            gameRef.resume();
          },
        );
}
