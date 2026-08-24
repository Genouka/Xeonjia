import 'package:xeonjia/game/xeonjia.dart';

/// Backpack menu
class BackpackMenu extends ItemsMenu {
  BackpackMenu(super.game)
    : super(
        text: 'Backpack'.i18n,
        items: () {
          List<Item> list = game.playerOne!.backpackItems.fold([], (l, e) {
            l.contains(e)
                ? l[l.indexOf(e)].quantity = l[l.indexOf(e)].quantity! + 1
                : l.add(Item(e.toMap())..quantity = 1);
            return l;
          });
          if (game.playerOne!.gemCount > 0) {
            list.add(
              Item({
                'id': 'gem_*',
                'name': 'Gems'.i18n,
                'description':
                    'Mysterious gems scattered around the world.'.i18n,
                'quantity': game.playerOne!.gemCount,
              }),
            );
          }
          return list;
        }(),
        onSelection: (Item item) {
          if (item.action != null) {
            // i18n: "Do you want to use {{selected-item-name}}?".i18n
            game.executeAction(
              action: '''
                  (begin
                    (dialog '(("Do you want to use {{selected-item-name}}?")))
                    (define id "generic-question")
                    (answer id '(("Yes" . #t) ("No" . #f)))
                    (wait)
                    (if (get id)
                      (begin
                        (remove-overlay "backpackMenu")
                        ${item.action!})))''',
            );
          }
        },
        onClose: () {
          game.overlays.remove('backpackMenu');
          game.overlays.remove('statusBox');
          game.overlays.add('statusBox');
          game.resume();
        },
      );
}
