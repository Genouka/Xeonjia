import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:xeonjia/ui/basic.dart';
import 'package:xeonjia/ui/screens/rules/resources/rules.dart';
import 'package:xeonjia/ui/screens/rules/widgets/last_page.dart';
import 'package:xeonjia/ui/screens/rules/widgets/rule_page.dart';
import 'package:xeonjia/util/local_data_controller.dart';

class RulesPage extends StatefulWidget {
  final StatelessWidget homePage;
  RulesPage([this.homePage]);

  @override
  _RulesPageState createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  final _textFieldController =
      TextEditingController(text: '${mainCharacter.name}');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _controller = TabController(vsync: this, length: rules().length + 1);
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading:
            _controller.index >= _controller.length - 1 || settings.firstRun
                ? Container()
                : IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                        size: 32),
                    tooltip: 'Close',
                    onPressed: () {
                      if (widget.homePage == null) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                            context, FadeRoute(widget.homePage));
                      }
                    },
                  ),
      ),
      body: TabBarView(controller: _controller, children: [
        for (var rule in rules()) RulePage(rule),
        LastPage(_textFieldController, _formKey, saveName),
      ]),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.navigate_before),
                    const Text('Back'),
                  ],
                ),
                onPressed: (_controller.index > 0)
                    ? () {
                        _controller.index -= (_controller.index > 0) ? 1 : 0;
                      }
                    : null,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      for (var i = 1; i < _controller.length - 1; i++)
                        CircleAvatar(
                          radius: _controller.index == i ? 4 : 3,
                          backgroundColor: _controller.index == i
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              : Colors.grey,
                        ),
                    ],
                  ),
                ),
              ),
              _controller.index >= _controller.length - 1
                  ? FlatButton(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        children: <Widget>[
                          const Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () {
                        saveName(_textFieldController.text);
                      },
                    )
                  : FlatButton(
                      child: Row(
                        children: <Widget>[
                          const Text('Next'),
                          const Icon(Icons.navigate_next)
                        ],
                      ),
                      onPressed: () {
                        if (_controller.index < _controller.length - 1) {
                          ++_controller.index;
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void saveName(String text) {
    if (_formKey.currentState?.validate() ?? false) {
      _textFieldController.text = text.trim();
      mainCharacter.name = _textFieldController.text;
      saveUserData();
      if (settings.firstRun) {
        settings.firstRun = false;
        saveSettings();
      }
      SystemChrome.restoreSystemUIOverlays();
      if (widget.homePage == null) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(context, FadeRoute(widget.homePage));
      }
    }
  }
}
