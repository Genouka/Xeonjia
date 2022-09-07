import 'dart:math';

import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/utils/extensions.dart';
import 'package:xeonjia/game/utils/message.dart';
import 'package:xeonjia/game/utils/sfx.dart';
import 'package:xeonjia/game/xeonjia_game.dart';
import 'package:xeonjia/utils/i18n.dart';

class DialogBox extends StatefulWidget {
  DialogBox(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  final GlobalKey<State<DialogBox>> key = GlobalKey();
  DialogBoxState? get state => key.currentState as DialogBoxState?;

  @override
  State<DialogBox> createState() => DialogBoxState();
}

class DialogBoxState extends State<DialogBox> with TickerProviderStateMixin {
  /// Show the next [Message] or hide [DialogBox] if there are no more messages
  void next({bool removeAnswers = false}) {
    if (_controller?.isAnimating ?? false) {
      _controller!.fling().whenComplete(() {
        if (mounted && widget.gameRef.messageManager.isShowingAQuestion) {
          setState(() {});
        }
      });
    } else {
      if (widget.gameRef.messageManager.hasOtherMessages) {
        widget.gameRef.messageManager.nextMessage();
        _animateText();
      } else if (removeAnswers ||
          !widget.gameRef.messageManager.isShowingAQuestion) {
        widget.gameRef.messageManager.clear();
      }
      widget.gameRef.playSound(Sfx.dialog);
      if (mounted) setState(() {});
    }
  }

  void refresh() {
    if (mounted) setState(() {});
    _animateText();
  }

  /// Typing text animation
  AnimationController? _controller;
  Animation<int>? _characterCountAnimation;
  void _animateText() {
    if (!widget.gameRef.messageManager.active ||
        (_controller?.isAnimating ?? false)) {
      return;
    }
    _controller = AnimationController(
      duration: Duration(
          milliseconds:
              35 * widget.gameRef.messageManager.currentMessage!.text.length),
      vsync: this,
    );
    _characterCountAnimation = StepTween(
            begin: 0,
            end: widget.gameRef.messageManager.currentMessage!.text.length)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    _controller!.forward().then((_) {
      _controller!.dispose();
      if (mounted && widget.gameRef.messageManager.isShowingAQuestion) {
        setState(() {});
      }
    });
  }

  double get opacity => widget.gameRef.isItemsMenuActive ? 1 : 0.8;
  String get author => widget.gameRef.messageManager.currentMessage!.authorName;

  @override
  Widget build(BuildContext context) {
    double imageScale =
        min(3, (MediaQuery.of(context).size.width ~/ 100).roundToDouble());
    if (_characterCountAnimation == null) _animateText();
    return Visibility(
      visible: widget.gameRef.messageManager.active,
      child: InkWell(
        enableFeedback: false,
        onTap: next,
        child: Stack(
          children: [
            if (widget.gameRef.messageManager.hideMap)
              Container(color: Colors.black),
            if (widget.gameRef.messageManager.active)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.gameRef.messageManager.isShowingAQuestion &&
                        _characterCountAnimation!.isCompleted)
                      _AnswerButtons(
                          widget.gameRef,
                          widget.gameRef.messageManager.answers,
                          () => next(removeAnswers: true)),
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(opacity),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.gameRef.messageManager.currentMessage!
                                  .sprite !=
                              null)
                            SizedBox(
                              width: 32 * imageScale.gridAligned.toDouble(),
                              child: Transform.scale(
                                scale: imageScale.gridAligned.toDouble(),
                                alignment: Alignment.bottomLeft,
                                child: SpriteWidget(
                                  sprite: widget.gameRef.messageManager
                                      .currentMessage!.sprite!,
                                ),
                              ),
                            ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              constraints: widget.gameRef.messageManager
                                          .currentMessage!.sprite !=
                                      null
                                  ? BoxConstraints(minHeight: 32 * imageScale)
                                  : null,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (author != '' && author != ' ')
                                      Text(
                                        '$author :'.toUpperCase(),
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    AnimatedBuilder(
                                      animation: _characterCountAnimation!,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Text(
                                          widget.gameRef.messageManager
                                              .currentMessage!.text
                                              .substring(
                                                  0,
                                                  _characterCountAnimation!
                                                      .value),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                fontFamily: widget
                                                    .gameRef
                                                    .messageManager
                                                    .currentMessage!
                                                    .font,
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
  const _AnswerButtons(this.gameRef, this.answers, this.callback);
  final XeonjiaGame gameRef;
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
                gameRef.currentEventLog[answer.questionId] = answer.value;
                gameRef.messageManager.clear();
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
