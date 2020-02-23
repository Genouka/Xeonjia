import 'package:flutter/material.dart';
import 'package:xeonjia/src/resources/global_variables.dart';

import 'package:xeonjia/src/screens/rules/resources/rules_list.dart';

class RulesPage extends StatefulWidget {
  @override
  _RulesPageState createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  // Page currently displayed
  int _page = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('R U L E S'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            /*Center(
                child: Container(
                    padding: EdgeInsets.only(top: 35),
                    child: Image(
                        image: AssetImage(ruleList[_page]['image']),
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width * 2 / 3))),*/
            Container(
              color: Colors.lightBlue[500],
              height: 40,
              width: double.infinity,
              child: Center(
                child: Text(
                  ruleList[_page]['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: kTextFontSize),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
                child: Text(
                  ruleList[_page]['text'],
                  style: const TextStyle(fontSize: kTextFontSize - 2),
                )),
          ],
        )),
        bottomNavigationBar: BottomAppBar(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              MaterialButton(
                child: Row(children: [
                  const Icon(Icons.keyboard_arrow_left),
                  const Text('Back')
                ]),
                onPressed: _page > 0
                    ? () => setState(() {
                          --_page;
                        })
                    : null,
              ),
              MaterialButton(
                  child: Row(children: [
                    const Text('Next'),
                    Icon(Icons.keyboard_arrow_right)
                  ]),
                  onPressed: _page < ruleList.length - 1
                      ? () => setState(() {
                            ++_page;
                          })
                      : null)
            ])),
      );
}
