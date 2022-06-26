import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xeonjia/game/util/extensions.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/models/message.dart';
import 'package:xeonjia/models/sfx.dart';
import 'package:xeonjia/util/i18n.dart';

class DialogBox extends StatefulWidget {
  DialogBox() : super(key: GlobalKey());
  DialogBoxState get state => (key as GlobalKey).currentState as DialogBoxState;

  @override
  State<DialogBox> createState() => DialogBoxState();
}

class DialogBoxState extends State<DialogBox> with TickerProviderStateMixin {
  // Show the next message or hide dialog box if there are no message to show
  void next({bool removeAnswers = false}) {
    if (_controller?.isAnimating ?? false) {
      _controller!.fling().whenComplete(() {
        if (mounted && game!.messageManager.isShowingAQuestion) setState(() {});
      });
    } else {
      if (game!.messageManager.hasOtherMessages) {
        game!.messageManager.nextMessage();
        _animateText();
      } else if (removeAnswers || !game!.messageManager.isShowingAQuestion) {
        game!.messageManager.clear();
      }
      game!.playSound(Sfx.dialog);
      if (mounted) setState(() {});
    }
  }

  void refresh() {
    if (mounted) setState(() {});
    _animateText();
  }

  // Typing text animation
  AnimationController? _controller;
  Animation<int>? _characterCountAnimation;
  void _animateText() {
    if (!game!.messageManager.active || (_controller?.isAnimating ?? false)) {
      return;
    }
    _controller = AnimationController(
      duration: Duration(
          milliseconds: 35 * game!.messageManager.currentMessage!.text.length),
      vsync: this,
    );
    _characterCountAnimation = StepTween(
            begin: 0, end: game!.messageManager.currentMessage!.text.length)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    _controller!.forward().then((_) {
      _controller!.dispose();
      if (mounted && game!.messageManager.isShowingAQuestion) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_characterCountAnimation == null) _animateText();
    return Visibility(
      visible: game!.messageManager.active,
      child: InkWell(
        enableFeedback: false,
        onTap: next,
        child: Stack(
          children: [
            if (game!.messageManager.hideMap) Container(color: Colors.black),
            if (game!.messageManager.active)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (game!.messageManager.isShowingAQuestion &&
                        _characterCountAnimation!.isCompleted)
                      _AnswerButtons(game!.messageManager.answers,
                          () => next(removeAnswers: true)),
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(0.8),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (game!.messageManager.currentMessage!.image !=
                              null)
                            Image.asset(
                              game!.messageManager.currentMessage!.image!,
                              height: (min(96,
                                      MediaQuery.of(context).size.width / 4))
                                  .gridAligned
                                  .toDouble(),
                              fit: BoxFit.fitHeight,
                              filterQuality: FilterQuality.none,
                            ),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((game!.messageManager.currentMessage!
                                            .authorName) !=
                                        '')
                                      Text(
                                        '${game!.messageManager.currentMessage!.authorName} :'
                                            .toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    AnimatedBuilder(
                                      animation: _characterCountAnimation!,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Text(
                                          game!.messageManager.currentMessage!
                                              .text
                                              .substring(
                                                  0,
                                                  _characterCountAnimation!
                                                      .value),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                fontFamily: game!.messageManager
                                                    .currentMessage!.font,
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons(this.answers, this.callback);
  final List<Answer> answers;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        border: Border.all(color: Colors.blue, width: 3),
      ),
      child: Column(
        children: [
          for (var answer in answers)
            TextButton(
              onPressed: () {
                game!.currentEventLog[answer.questionId] = answer.value;
                game!.messageManager.clear();
                callback();
              },
              child: Container(
                constraints: const BoxConstraints(minWidth: 120),
                child: Text(
                  answer.text.i18n,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
