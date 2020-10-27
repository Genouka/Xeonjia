import 'package:flutter/material.dart';

import 'package:xeonjia/ui/screens/rules/util/rule.dart';

class RulePage extends StatelessWidget {
  final Rule rule;
  RulePage(this.rule) : assert(rule.image != null || rule.icon != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 60, bottom: 60),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  width: 275,
                  height: 275,
                  decoration: rule.image != null
                      ? BoxDecoration(
                          image: DecorationImage(image: AssetImage(rule.image)),
                        )
                      : null,
                  child: Icon(rule.icon, size: rule.iconSize),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text(
                  rule.title,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(
                      rule.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, height: 1.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
