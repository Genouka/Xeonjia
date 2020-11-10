import 'package:flutter/material.dart';

import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/sfx.dart';

class DialogBox extends StatefulWidget {
  @override
  final GlobalKey<_DialogBoxState> key = GlobalKey();
  _DialogBoxState get state => key.currentState;

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> with TickerProviderStateMixin {
  // Show the next message or hide dialog box if there are no message to show
  void next() {
    if (_controller?.isAnimating ?? false) {
      _controller.fling();
    } else {
      game.messageManager.hasOtherMessages()
          ? _animateText()
          : game.messageManager.clear();
      game.playSound(Sfx.dialog);
      if (mounted) setState(() {});
    }
  }

  void refresh() {
    if (mounted) setState(() {});
    _animateText();
  }

  // Typing text animation
  AnimationController _controller;
  Animation<int> _characterCountAnimation;
  void _animateText() {
    if (!game.messageManager.active || (_controller?.isAnimating ?? false)) {
      return;
    }
    _controller = AnimationController(
      duration: Duration(
          milliseconds: 35 * game.messageManager.currentMessage.text.length),
      vsync: this,
    );
    _characterCountAnimation = StepTween(
            begin: 0, end: game.messageManager.currentMessage.text.length)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.forward().then((_) => _controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    if (_characterCountAnimation == null) _animateText();
    return Visibility(
      visible: game.messageManager.active,
      child: InkWell(
        enableFeedback: false,
        onTap: next,
        child: Stack(
          children: [
            if (game.messageManager.hideMap ?? false)
              Container(color: Colors.black),
            if (game.messageManager.active)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: Colors.grey[800].withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (game.messageManager.currentMessage.image != null)
                        Image.asset(
                          game.messageManager.currentMessage.image,
                          height: 96.gridAligned,
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.none,
                        ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((game.messageManager.currentMessage
                                      .authorName) !=
                                  '')
                                Text(
                                  '${game.messageManager.currentMessage.authorName} :',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              AnimatedBuilder(
                                animation: _characterCountAnimation,
                                builder: (BuildContext context, Widget child) {
                                  return Text(
                                    game.messageManager.currentMessage.text
                                        .substring(
                                            0, _characterCountAnimation.value),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
