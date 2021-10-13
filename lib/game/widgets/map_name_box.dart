import 'package:flutter/material.dart';
import 'package:xeonjia/game/widgets/info_box.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/i18n/story.i18n.dart';

// Map name shown on the top left of the screen
class MapNameBox extends StatelessWidget {
  final String text;
  final bool below;
  MapNameBox({this.below = true}) : text = game.map.name;

  @override
  Widget build(BuildContext context) {
    return text != null
        ? InfoBox(
            below: below,
            child: Marquee(
              child: Text(
                text.i18n.toUpperCase() + ' ',
                style: Theme.of(context).textTheme.button,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          )
        : Container();
  }
}

class Marquee extends StatefulWidget {
  final Widget child;
  const Marquee({@required this.child});

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  ScrollController scrollController =
      ScrollController(initialScrollOffset: -50);

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

  void scroll(_) async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 2700),
        curve: Curves.ease,
      );
    }
  }
}
