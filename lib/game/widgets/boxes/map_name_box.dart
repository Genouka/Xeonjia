import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

/// Map name shown on the top left of the screen
class MapNameBox extends StatelessWidget {
  MapNameBox(this.game, {this.below = false}) : text = game.map.name;
  final XeonjiaGame game;
  final String? text;
  final bool below;

  @override
  Widget build(BuildContext context) {
    return text != null
        ? InfoBox(
            onTap: () => game.messageManager.isActive
                ? null
                : game.pause(mode: PauseMode.pause),
            below: below,
            child: Marquee(
              child: Text(
                text!.i18n.toUpperCase() + ' ',
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
              ),
            ),
          )
        : Container();
  }
}

class Marquee extends StatefulWidget {
  const Marquee({required this.child});
  final Widget child;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  ScrollController scrollController = ScrollController(
    initialScrollOffset: -50,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(scroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: widget.child,
    ),
  );

  void scroll(Duration _) async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 2700),
        curve: Curves.ease,
      );
    }
  }
}
