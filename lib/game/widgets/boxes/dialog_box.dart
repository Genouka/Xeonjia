import 'dart:math';

import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

class DialogBox extends StatefulWidget {
  DialogBox(this.gameRef);
  final XeonjiaGame gameRef;

  @override
  final GlobalKey<State<DialogBox>> key = GlobalKey();
  DialogBoxState? get state => key.currentState as DialogBoxState?;

  @override
  State<DialogBox> createState() => DialogBoxState();
}

/// Currently selected answer (for keyboard input)
int selectedAnswerIndex = 0;

class DialogBoxState extends State<DialogBox> with TickerProviderStateMixin {
  /// Show the next [Message] or hide [DialogBox] if there are no more messages
  void next({bool removeAnswers = false}) {
    selectedAnswerIndex = 0;
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

  /// True if answers are shown
  bool get isShowingAnswers =>
      widget.gameRef.messageManager.isShowingAQuestion &&
      _characterCountAnimation!.isCompleted;

  /// Select the next answer
  void selectNextAnswer() {
    setState(() {
      if (++selectedAnswerIndex >=
          widget.gameRef.messageManager.answers.length) {
        selectedAnswerIndex = 0;
      }
    });
  }

  /// Select the previous answer
  void selectPreviousAnswer() {
    setState(() {
      if (--selectedAnswerIndex < 0) {
        selectedAnswerIndex = widget.gameRef.messageManager.answers.length - 1;
      }
    });
  }

  /// Choose the currently selected answer
  void chooseAnswer() {
    widget.gameRef.messageManager.chooseAnswer(
        widget.gameRef.messageManager.answers[selectedAnswerIndex]);
  }

  /// Typing text animation
  AnimationController? _controller;
  Animation<int>? _characterCountAnimation;
  void _animateText() {
    if (!widget.gameRef.messageManager.isActive ||
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
      visible: widget.gameRef.messageManager.isActive,
      child: InkWell(
        enableFeedback: false,
        onTap: next,
        child: Stack(
          children: [
            if (widget.gameRef.messageManager.hideMap)
              Container(color: Colors.black),
            if (widget.gameRef.messageManager.isActive)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isShowingAnswers)
                      _AnswerButtons(widget.gameRef,
                          widget.gameRef.messageManager.answers),
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
                                            .bodyLarge,
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
                                                  min(
                                                      widget
                                                          .gameRef
                                                          .messageManager
                                                          .currentMessage!
                                                          .text
                                                          .length,
                                                      _characterCountAnimation!
                                                          .value)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
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
  const _AnswerButtons(this.gameRef, this.answers);
  final XeonjiaGame gameRef;
  final List<Answer> answers;

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
              onPressed: () => gameRef.messageManager.chooseAnswer(answer),
              child: Container(
                constraints: const BoxConstraints(minWidth: 120),
                child: Text(
                  (answers.indexOf(answer) == selectedAnswerIndex ? '> ' : '') +
                      answer.text.i18n,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
