import 'dart:math';

import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:xeonjia/game/xeonjia.dart';

class DialogBox extends StatefulWidget {
  DialogBox(this.game);
  final XeonjiaGame game;

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
        if (mounted && widget.game.messageManager.isShowingAQuestion) {
          setState(() {});
        }
      });
    } else {
      if (widget.game.messageManager.hasOtherMessages) {
        widget.game.messageManager.nextMessage();
        _animateText();
      } else if (removeAnswers ||
          !widget.game.messageManager.isShowingAQuestion) {
        widget.game.messageManager.clear();
      }
      widget.game.playSound(Sfx.dialog);
    }
    if (mounted) setState(() {});
  }

  void refresh() {
    if (mounted) setState(() {});
    _animateText();
  }

  /// True if answers are shown
  bool get isShowingAnswers =>
      widget.game.messageManager.isShowingAQuestion &&
      _characterCountAnimation!.isCompleted;

  /// Select the next answer
  void selectNextAnswer() {
    setState(() {
      if (++selectedAnswerIndex >= widget.game.messageManager.answers.length) {
        selectedAnswerIndex = 0;
      }
    });
  }

  /// Select the previous answer
  void selectPreviousAnswer() {
    setState(() {
      if (--selectedAnswerIndex < 0) {
        selectedAnswerIndex = widget.game.messageManager.answers.length - 1;
      }
    });
  }

  /// Choose the currently selected answer
  void chooseAnswer() {
    widget.game.messageManager.chooseAnswer(
      widget.game.messageManager.answers[selectedAnswerIndex],
    );
  }

  /// Typing text animation
  AnimationController? _controller;
  Animation<int>? _characterCountAnimation;
  void _animateText() {
    if (!widget.game.messageManager.isActive ||
        (_controller?.isAnimating ?? false)) {
      return;
    }
    _controller = AnimationController(
      duration: Duration(
        milliseconds:
            35 * widget.game.messageManager.currentMessage!.text.length,
      ),
      vsync: this,
    );
    _characterCountAnimation = StepTween(
      begin: 0,
      end: widget.game.messageManager.currentMessage!.text.length,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    _controller!.forward().then((_) {
      _controller!.dispose();
      if (mounted && widget.game.messageManager.isShowingAQuestion) {
        setState(() {});
      }
    });
  }

  void pauseAnimation() =>
      _controller?.isAnimating ?? false ? _controller?.stop() : null;
  void resumeAnimation() =>
      _controller?.isCompleted ?? true ? null : _controller?.forward();

  double get opacity => widget.game.isItemsMenuActive ? 1 : 0.85;
  String get author => widget.game.messageManager.currentMessage!.authorName;

  @override
  Widget build(BuildContext context) {
    double imageScale = min(
      3,
      (MediaQuery.of(context).size.width ~/ 100).roundToDouble(),
    );
    if (_characterCountAnimation == null) _animateText();
    return Visibility(
      visible: widget.game.messageManager.isActive,
      child: InkWell(
        enableFeedback: false,
        onTap: next,
        child: Stack(
          children: [
            if (widget.game.messageManager.hideMap)
              Container(color: Colors.black),
            if (widget.game.messageManager.isActive)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isShowingAnswers)
                      _AnswerButtons(
                        widget.game,
                        widget.game.messageManager.answers,
                      ),
                    Container(
                      margin: widget.game.isItemsMenuActive
                          ? EdgeInsets.only(
                              bottom: 5.gridAligned.toDouble(),
                              top: 20,
                              left: 20,
                              right: 20,
                            )
                          : const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withAlpha(
                          (255.0 * opacity).round(),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget
                                  .game
                                  .messageManager
                                  .currentMessage!
                                  .sprite !=
                              null)
                            SizedBox(
                              width: 32 * imageScale.gridAligned.toDouble(),
                              child: Transform.scale(
                                scale: imageScale.gridAligned.toDouble(),
                                alignment: Alignment.bottomLeft,
                                child: SpriteWidget(
                                  sprite: widget
                                      .game
                                      .messageManager
                                      .currentMessage!
                                      .sprite!,
                                ),
                              ),
                            ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              constraints:
                                  widget
                                          .game
                                          .messageManager
                                          .currentMessage!
                                          .sprite !=
                                      null
                                  ? BoxConstraints(minHeight: 32 * imageScale)
                                  : null,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (author != '' && author != ' ')
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          author.toUpperCase(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ),
                                    AnimatedBuilder(
                                      animation: _characterCountAnimation!,
                                      builder:
                                          (
                                            BuildContext context,
                                            Widget? child,
                                          ) {
                                            return Text(
                                              widget
                                                  .game
                                                  .messageManager
                                                  .currentMessage!
                                                  .text
                                                  .substring(
                                                    0,
                                                    min(
                                                      widget
                                                          .game
                                                          .messageManager
                                                          .currentMessage!
                                                          .text
                                                          .length,
                                                      _characterCountAnimation!
                                                          .value,
                                                    ),
                                                  ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontFamily: widget
                                                        .game
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
  const _AnswerButtons(this.game, this.answers);
  final XeonjiaGame game;
  final List<Answer> answers;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withAlpha((255.0 * 0.8).round()),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        border: Border.all(color: Colors.blue, width: 3),
      ),
      child: Column(
        children: [
          for (final answer in answers)
            TextButton(
              onPressed: () => game.messageManager.chooseAnswer(answer),
              style: ButtonStyle(
                overlayColor: WidgetStateColor.resolveWith(
                  (states) => Colors.transparent,
                ),
              ),
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
