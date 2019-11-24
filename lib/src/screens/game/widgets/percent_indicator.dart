// flutter_percent_indicator (edited)
// Original repo: https://github.com/diegoveloper/flutter_percent_indicator/

/* BSD 2-Clause License
*
* Copyright (c) 2018, diegoveloper@gmail.com
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* * Redistributions of source code must retain the above copyright notice, this
* list of conditions and the following disclaimer.
*
* * Redistributions in binary form must reproduce the above copyright notice,
* this list of conditions and the following disclaimer in the documentation
* and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:xeonjia/src/resources/global_variables.dart';

enum LinearStrokeCap { butt, round, roundAll }

class LinearPercentIndicator extends StatefulWidget {
  final _LinearPercentIndicatorState state = _LinearPercentIndicatorState();

  ///Percent value between 0.0 and 1.0
  final double percent;
  final double width;

  ///Height of the line
  final double lineHeight;

  ///Color of the background of the Line , default = transparent
  final Color fillColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the left of the Line
  final Widget leading;

  ///widget at the right of the Line
  final Widget trailing;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, roundAll
  final LinearStrokeCap linearStrokeCap;

  ///alignment of the Row (leading-widget-center-trailing)
  final MainAxisAlignment alignment;

  ///padding to the LinearPercentIndicator
  final EdgeInsets padding;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set true if you want to animate the linear from the right to left (RTL)
  final bool isRTL;

  LinearPercentIndicator(
      {Key key,
      this.fillColor = Colors.transparent,
      this.percent,
      this.lineHeight = 40.0,
      this.width,
      this.animation = false,
      this.animationDuration = 100,
      this.animateFromLastPercent = false,
      this.isRTL = false,
      this.leading,
      this.trailing,
      this.addAutomaticKeepAlive = true,
      this.linearStrokeCap = LinearStrokeCap.butt,
      this.padding = const EdgeInsets.symmetric(horizontal: 0.0),
      this.alignment = MainAxisAlignment.start})
      : super(key: key);

  @override
  _LinearPercentIndicatorState createState() => state;
}

class _LinearPercentIndicatorState extends State<LinearPercentIndicator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _animationController;
  Animation _animation;
  double _percent = 1;
  String _text = '';
  bool _poison = false;
  Color _progressColor = Color(0xFF0288D1);

  void refresh({@required double percent, @required String text, bool poison}) {
    _percent = percent;
    _text = text;
    _poison = poison ?? false;
    if (_percent < 0)
      _percent = 0;
    else if (_percent > 1) _percent = 1;
    _updateColor();
    if (mounted) setState(() {});
  }

  void _updateColor() {
    if (_poison)
      _progressColor = const Color(0xFF7B1FA2);
    else if (_percent < 0.15)
      _progressColor = const Color(0xFFBF360C);
    else if (_percent < 0.3)
      _progressColor = const Color(0xFFF57F17);
    else
      _progressColor = const Color(0xFF0288D1);
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation =
          Tween(begin: 0.0, end: widget.percent).animate(_animationController)
            ..addListener(() {
              setState(() {
                _percent = _animation.value;
              });
            });
      _animationController.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(LinearPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      if (_animationController != null) {
        _animationController.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation = Tween(
                begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0,
                end: widget.percent)
            .animate(_animationController);
        _animationController.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
  }

  _updateProgress() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List<Widget>();
    if (widget.leading != null) {
      items.add(widget.leading);
    }
    final hasSetWidth = widget.width != null;
    Container containerWidget = Container(
      width: hasSetWidth ? widget.width : double.infinity,
      height: widget.lineHeight,
      padding: widget.padding,
      child: CustomPaint(
        painter: LinearPainter(
            isRTL: widget.isRTL,
            progress: _percent,
            progressColor: _progressColor.withOpacity(0.6),
            backgroundColor: Colors.lightBlue[100].withOpacity(0.7),
            linearStrokeCap: widget.linearStrokeCap,
            lineWidth: widget.lineHeight),
        child: Center(
            child: Text(
          _text,
          style: TextStyle(fontSize: kTextFontSize),
        )),
      ),
    );

    if (hasSetWidth) {
      items.add(containerWidget);
    } else {
      items.add(Expanded(
        child: containerWidget,
      ));
    }
    if (widget.trailing != null) {
      items.add(widget.trailing);
    }
    super.build(context);

    return Material(
      color: Colors.transparent,
      child: new Container(
          color: widget.fillColor,
          child: Row(
            mainAxisAlignment: widget.alignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items,
          )),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class LinearPainter extends CustomPainter {
  final Paint _paintBackground = new Paint();
  final Paint _paintLine = new Paint();
  final lineWidth;
  final progress;
  final center;
  final isRTL;
  final Color progressColor;
  final Color backgroundColor;
  final LinearStrokeCap linearStrokeCap;

  LinearPainter(
      {this.lineWidth,
      this.progress,
      this.center,
      this.isRTL,
      this.progressColor,
      this.backgroundColor,
      this.linearStrokeCap = LinearStrokeCap.butt}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = lineWidth;

    _paintLine.color = progress.toString() == '0.0'
        ? progressColor.withOpacity(0.0)
        : progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    if (linearStrokeCap == LinearStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (linearStrokeCap == LinearStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.round;
      _paintBackground.strokeCap = StrokeCap.round;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(0.0, size.height / 2);
    final end = Offset(size.width, size.height / 2);
    canvas.drawLine(start, end, _paintBackground);
    if (isRTL) {
      canvas.drawLine(
          end,
          Offset(size.width - (size.width * progress), size.height / 2),
          _paintLine);
    } else {
      canvas.drawLine(
          start, Offset(size.width * progress, size.height / 2), _paintLine);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
