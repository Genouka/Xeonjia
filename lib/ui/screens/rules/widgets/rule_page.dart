import 'package:flutter/material.dart';
import 'package:xeonjia/ui/screens/rules/utils/rule.dart';

class RulePage extends StatelessWidget {
  RulePage(this.rule) : assert(rule.image != null || rule.icon != null);
  final Rule rule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 60, bottom: 60),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: rule.image != null
                        ? DecorationImage(image: AssetImage(rule.image!))
                        : null,
                  ),
                  child: Icon(rule.icon,
                      size: MediaQuery.of(context).size.shortestSide / 3),
                ),
              ),
              Text(
                rule.title,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      top: MediaQuery.of(context).size.longestSide / 14),
                  child: Text(
                    rule.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
