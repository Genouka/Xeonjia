import 'package:xeonjia/game/models/item.dart';
import 'package:xeonjia/game/widgets/menus/items_menu.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

/// Backpack menu
class BackpackMenu extends ItemsMenu {
  BackpackMenu(XeonjiaGame gameRef)
      : super(
          gameRef,
          text: 'Backpack'.i18n,
          items: () {
            List<Item> list = gameRef.playerOne!.backpackItems.fold([], (l, e) {
              l.contains(e)
                  ? l[l.indexOf(e)].quantity = l[l.indexOf(e)].quantity! + 1
                  : l.add(Item(e.toMap())..quantity = 1);
              return l;
            });
            if (gameRef.playerOne!.gemCount > 0) {
              list.add(Item({
                'id': 'gem_*',
                'name': 'Gems'.i18n,
                'description':
                    'Mysterious gems scattered around the world.'.i18n,
                'quantity': gameRef.playerOne!.gemCount,
              }));
            }
            return list;
          }(),
          onSelection: (Item item) {
            if (item.action != null) {
              // i18n: "Do you want to use {{selected-item-name}}?".i18n
              gameRef.executeAction(action: '''
                  (begin
                    (dialog '(("Do you want to use {{selected-item-name}}?")))
                    (define id "generic-question")
                    (answer id '(("Yes" . #t) ("No" . #f)))
                    (wait)
                    (if (get id)
                      (begin
                        (remove-overlay "backpackMenu")
                        ${item.action!})))''');
            }
          },
          onClose: () {
            gameRef.overlays.remove('backpackMenu');
            gameRef.resume();
          },
        );
}
